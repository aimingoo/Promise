
--wall-clock time, monotonic time and sleeping for Windows, Linux and OSX.
--Written by Cosmin Apreutesei. Public Domain.

local ffi = require'ffi'

local M = {}
local C = ffi.C

if ffi.os == 'Windows' then

	ffi.cdef[[
	void GetSystemTimeAsFileTime(uint64_t*);
	int  QueryPerformanceCounter(int64_t*);
	int  QueryPerformanceFrequency(int64_t*);
	void Sleep(uint32_t ms);
	]]

	local t = ffi.new'uint64_t[1]'
	local DELTA_EPOCH_IN_100NS = 116444736000000000ULL

	function M.time()
		C.GetSystemTimeAsFileTime(t)
		return tonumber(t[0] - DELTA_EPOCH_IN_100NS) / 10^7
	end

	assert(C.QueryPerformanceFrequency(t) ~= 0)
	local qpf = tonumber(t[0])

	function M.clock()
		assert(C.QueryPerformanceCounter(t) ~= 0)
		return tonumber(t[0]) / qpf
	end

	function M.sleep(s)
		C.Sleep(s * 1000)
	end

elseif ffi.os == 'Linux' or ffi.os == 'OSX' then

	ffi.cdef[[
	typedef struct {
		long s;
		long ns;
	} t_timespec;

	int nanosleep(t_timespec*, t_timespec *);
	]]

	local EINTR = 4

	local t = ffi.new't_timespec'

	function M.sleep(s)
		local int, frac = math.modf(s)
		t.s = int
		t.ns = frac * 10^9
		local ret = C.nanosleep(t, t)
		while ret == -1 and ffi.errno() == EINTR do --interrupted
			ret = C.nanosleep(t, t)
		end
		assert(ret == 0)
	end

	if ffi.os == 'Linux' then

		ffi.cdef[[
		int clock_gettime(int clock_id, t_timespec *tp);
		]]

		local CLOCK_REALTIME = 0
		local CLOCK_MONOTONIC = 1

		local clock_gettime = ffi.load'rt'.clock_gettime

		local function tos(t)
			return tonumber(t.s) + tonumber(t.ns) / 10^9
		end

		function M.time()
			assert(clock_gettime(CLOCK_REALTIME, t) == 0)
			return tos(t)
		end

		function M.clock()
			assert(clock_gettime(CLOCK_MONOTONIC, t) == 0)
			return tos(t)
		end

	elseif ffi.os == 'OSX' then

		ffi.cdef[[
		typedef struct {
			long    s;
			int32_t us;
		} t_timeval;

		typedef struct {
			uint32_t numer;
			uint32_t denom;
		} t_mach_timebase_info_data_t;

		int      gettimeofday(t_timeval*, void*);
		int      mach_timebase_info(t_mach_timebase_info_data_t* info);
		uint64_t mach_absolute_time(void);
		]]

		local t = ffi.new't_timeval'

		function M.time()
			assert(C.gettimeofday(t, nil) == 0)
			return tonumber(t.s) + tonumber(t.us) / 10^6
		end

		--NOTE: this appears to be pointless on Intel Macs. The timebase fraction
		--is always 1/1 and mach_absolute_time() does dynamic scaling internally.
		local timebase = ffi.new't_mach_timebase_info_data_t'
		assert(C.mach_timebase_info(timebase) == 0)
		local scale = tonumber(timebase.numer) / tonumber(timebase.denom) / 10^9
		function M.clock()
			return tonumber(C.mach_absolute_time()) * scale
		end

	end --OSX

end --Linux or OSX

if not ... then
	io.stdout:setvbuf'no'
	local time = M

	print('time ', time.time())
	print('clock', time.clock())

	local function test_sleep(s, ss)
		local t0 = time.clock()
		local times = s*1/ss
		print(string.format('sleeping %gms in %gms increments (%d times)...', s * 1000, ss * 1000, times))
		for i=1,times do
			time.sleep(ss)
		end
		local t1 = time.clock()
		print(string.format('  missed by: %0.2fms', (t1 - t0 - s) * 1000))
	end

	test_sleep(0.001, 0.001)
	test_sleep(0.2, 0.02)
	test_sleep(2, 0.2)
end

return M
