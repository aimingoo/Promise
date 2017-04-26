# Promise
The Promise module in Lua. Simple, Fast and ES6 Promises full supported/compatibled.

about ES6 Promises see here: [Promise in MDN](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise)

a chinese document at here: [The Promise's World](http://blog.csdn.net/aimingoo/article/details/47401961)

###Table of Contents
* [Install &amp; Usage](#install--usage)
* [Interface](#interface)
* [testcase or samples](#testcase-or-samples)
* [History](#history)


# Install & Usage
download the Promise.lua file and put into lua search path or current directory, and load it as a file module from lua. 

or use luarocks and require as module:
```bash
> luarocks install promise-es6
```

and, use Promise.new() or use Promise.xxx method to get promise object.
```lua
Promise = require('Promise')

p1 = Promise.new(function(resolve, reject)
  resolve('your immediate value, or result from remote query or asynchronous call')
end)

p2 = Promise.resolve('immediate value')

p1:andThen(function(value)
  print(value)
  return 'something'
end):andThen(..)   -- more
```

# Interface

for the Promsie, call with '.':

> - Promise.new(executor);
> ```lua
> promise = Promise.new(function(resolve, reject) .. end);
> ```
```
>
> - Promise.all(array);
​```lua
promise = Promise.all(array)	-- a table as array
```
>
>- Promise.race(array)	-- a table as array
```lua
promise = Promise.race(array)	-- a table as array
```
>
>- Promise.reject(reason)
```lua
promise = Promise.reject(reason);	-- reason is anything
```
>
>- Promise.resolve(value)
```lua
promise = Promise.resolve(value);
promise = Promise.resolve(thenable);
promise = Promise.resolve(promise);
```

for promise instance, call with ':':
> - promise:andThen(onFulfilled, onRejected)
```lua
promise2 = promise:andThen(functoin(value) ... end);
promise2 = promise:andThen(nil, functoin(reson) ... end);
```
>
>- promise:catch(onRejected)
```lua
promise2 = promise:catch(functoin(reson) ... end)
```

# testcase or samples
This is a base testcase:
```lua
---
--- from testcase/t_base_test.lua
---
Promise = require('Promise')

A = function() return 10 end
B = function(a) print(a * 2) end
C = function(a)
	print(a * 4)
	return Promise.resolve('ok')  -- or direct return 'ok'
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
promise_B = promise_A:andThen(B)
promise_C = promise_A:andThen(C)
promise_D = promise_A:andThen(D)

promises = {promise_B, promise_C, promise_D}
Promise.all(promises)
	:andThen(E)
	:catch(function(reson)
		print(reson)
	end)
```
# History
--	2017.04.26	release v1.2, fix some bugs

>	- fix bug: value deliver on promise chain, about issue-#3, thanks for @stakira
>	- ignore rewrite promised value

--	2015.10.29	release v1.1, fix some bugs

> 	- update testcases
> 	- update: add .catch() for promised string
> 	- update: protect call in .new method
> 	- fix bug: resolver values when multi call .then()
> 	- fix bug: non standard .reject() implement
> 	- fix bug: some error in .all() and .race() methods

--	2015.08.10	release v1.0.1, full testcases, minor fix and publish on github

--	2015.03		release v1.0.0
