# Benchmarker
A roblox lua module that allows you to benchmark functions, it benchmarks through two ways, the average time it took to call the function for a given amount of cycles. And the total amount of cycles for a given duration. You can also directly compare two methods.

## TOC
- [Download](#Download)
- [Customization](#Customization)
- [Code examples](#Code-examples)
- [API](#API)
- [Notes](#Notes)

## Download 
- [from the release page](https://github.com/VerdommeMan/Benchmarker/releases)
- [link to roblox asset page](https://www.roblox.com/library/6240410557/ReadableNumbers)
- or you can build it from [src](src/) using rojo


## Customization

### cycles
You can set the amount times the function will be called for calculating the average time per call. By default it does a 1000 cycles.

### duration
You can set the duration (in seconds). This is used for calculating the amount of cycles for a given duration. By default it has a duration of 1 second.

### showProgress
This boolean controls if it should print the current progress on the benchmark. It will perodically print the current completion. It is off by default.

### showFullInfo
This boolean controls if it should print the full info. It is on by default and turning it off will only show the minimal amount of prints.

### ReadableNumbers
Here you can pass a ReadableNumbers object. Which converts numbers into a human readable format. For example 4.14001e-08 s -> 41.4 ns. You can turn this feature off by passing a false. You can customize it by passing your own ReadableNumbers object. see [ReadableNumbers](https://github.com/VerdommeMan/convert-to-human-readable-numbers) on the specifics.

### noYieldTime
The time in seconds in which it wont yield. By default it is 0.1 s. Which means it will only yield every 0.1 s. You can increase this number to have faster benchmarks but if you are getting "Script timeout: exhausted allowed execution time" errors, lower this number.

## Code examples

```lua
local ServerScriptService = game:GetService('ServerScriptService')

local Benchmarker = require(ServerScriptService:WaitForChild("Benchmarker"))

Benchmarker:benchmark(math.floor, 10.4144) -- will output the results for doing 1000 cycles and amount of cycles it did in 1s (default settings)

Benchmarker:compare(math.floor, math.round, 1, 10.4144, 10.4144 ) -- will print the results of each benchmark and print how much faster/slower function1 is compared to function2

local benchmark = Benchmarker.new(1e4, 10, true) -- create a benchmark object with our own configuration, showProgress has been set to to true so that you can see how long it takes for it to complete

-- test setup for ipairs vs pairs
local tbl = table.create(1e6,"t") -- create a table with 1 million entries of "t"

local function testIpairs()
    for _ in ipairs(tbl) do
        
    end
end

local function testPairs()
    for _ in pairs(tbl) do
        
    end
end

benchmark:compare(testIpairs, testPairs) -- Ipairs has always been faster in my comparisons

benchmark.cycles = 10 -- you can also change the settings directly through the properties

local ReadableNumbers = require(ServerScriptService:WaitForChild("Benchmarker"):WaitForChild("ReadableNumbers")) -- ReadableNumbers module

local readableNumbers = ReadableNumbers.new(2, false, "") -- create our own configuration for readablenumbers, we set a precision of 2, make it not remove trailing zeros and put no delimiter between the prefix and the number

local benchmark2 = Benchmarker.new(1e6, 2, false, false, readableNumbers)

local function testInsert(tbl, val)
    tbl[#tbl + 1] = val
end

benchmark2:compare(table.insert, testInsert, 2, tbl, "T", tbl, "T") -- second should always be faster until luau adds the optimizations for table.insert but yet table.insert is a bit faster here in this comparison that is because `tbl[#tbl + 1] = val` is wrapped in a function which adds more overhead and which makes it slower than table.insert

-- this proves the above statement
local newTbl, newTbl2, newTbl3 = {}, {}, {}

local start = os.clock()
for i =1, 1e6 do
    table.insert(newTbl, "t") 
end
print(os.clock() - start) -- middle

local start1 = os.clock()
for i =1, 1e6 do
    testInsert(newTbl2, "t")
end
print(os.clock() - start1) -- slowest

local start2 = os.clock()
for i =1, 1e6 do
    newTbl3[#newTbl3 + 1] = "t"
end
print(os.clock() - start2) -- fastest
```

## API
Is in the form of `returnType` **function**(argumentName:`type`, argumentName:`type` defaultValue)

### Constructors

`Benchmarker` **Benchmarker.new**(cycles: `int` 1e3, duration: `number` 1, showProgress: `bool` false, showFullInfo: `bool` true, ReadableNumbers: `false|ReadableNumbers` ReadableNumbers.new(), noYieldTime: `number` 0.1)

It returns a Benchmarker instance, all properties can be changed by indexing the argument name. See customization on what each argument does.

### Methods

#### `void` **Benchmarker:compare**(func1: `function`, func2: `function`, func1AmountArgs: `number`, ...)
This method does a comparison of the functions on the two modes using the default settings. `func1AmountArgs` splits the vararg on that index. For example:  compare(math.floor, math.round, 1, 10, 15), math.floor gets 10 and math.round gets 15, Another example  compare(select, math.round, 4, 2, "A" , "B", "C", 15) which `2, "A" , "B", "C"` go to select and math.round gets 15.
The reason for the func1AmountArgs is that it needs to split the varags between the two given functions. It prints the results to the output.

#### `void` **Benchmarker:benchmark**(func: `function`, ...)
This method prints the result of both modes (cycles for given amount of duration, average tim per cycle of given amount of cycles). The vararg will be passed as the arguments to the function.

### `tuple` avgTimePerCycleInSec: `number`, totalTime: `number` **Benchmarker:getAvg**(func: `function`, ...)
This method calculates the average time a cycle took for the set amount of cycles. This method is internally used by compare and benchmark. It returns a tuple with the first value the average time per cycle in seconds and the second value the total time it took for all the cycles in seconds.

### `tuple` amount: `number`, amountPerSec: `number`, totalTime: `number` **Benchmarker:getCycles**(func: `function`, ...)
This method calcualtes how many times the function can be called for a set duration (in seconds). his method is internally used by compare and benchmark. It returns a tuple with the first value the total amount times the function has been called for the set duration. The second value is the amount per second. The third value is the actual amount of duration it took, this should always the be same as the set duration.

## Notes
- It does only type checking for the arguments, so if you set the properties manually you can set a wrong type.
- When getting "Script timeout: exhausted allowed execution time" lower the `noYieldTime`.
- The module yields by default 3s. This allows the server/client to fully start so that it can make more consistent benchmarks

