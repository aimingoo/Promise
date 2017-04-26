---------------------------------------------------------------
---		Base demo of promise framework
---------------------------------------------------------------
-- The testcase: Do A(), and do B,C,D, and do E() base a,b,c
--	*) print messages:
--		20
--		andThen:	nil
--		40
--		30
--		nil	ok	nil
--	*) and catch a reson:
--		FIRE
---------------------------------------------------------------

-- Promise = require('Promise')
Promise = dofile('../Promise.lua')

A = function() return 10 end
B = function(a) print(a * 2) end
C = function(a)
	print(a * 4)
	-- return Promise.resolve('ok')
	return 'ok'
end
D = function(a) print(a * 3) end
E = function(result)
	local b, c, d = unpack(result)
	print(b, c, d)
	return Promise.reject('FIRE')
end

-- promise_A = Promise.resolve(A())
promise_A = Promise.new(function(resolve, reject)
	local ok, result = pcall(A)
	return (ok and resolve or reject)(result)
end)
-- promise_B = promise_A:andThen(B)
local err = function(r) print("catch:", r) end
local log = function(r) print("andThen:", r); return r end
promise_B = promise_A:andThen(B):catch(err):andThen(log)

promise_C = promise_A:andThen(C)
promise_D = promise_A:andThen(D)

promises = {promise_B, promise_C, promise_D}
Promise.all(promises)
	:andThen(E)
	:catch(print)
