---
title: the go programming language book notes
date: 2022-08-04T20:26:00Z
slug: learning-golang
tags:
- golang
---

{{< aside >}}
These are notes that I took while reading the [The Go Prgogramming Language book](https://www.gopl.io/)
{{< /aside >}}


### Interesting points

- Go has some strictness when it comes to compiling
  - if packages are imported but not used - don't compile
  - if a newline is placed incorrectly - don't compile. Newlines follwing certain tokens are converted to semicolons automatically
  - Semicolons are used only when statements are to be written in one line one after another.
  - if local variables are not used - don't compile
- Go also has strict code formatting rules built-in, which makes it standard everywhere.
  - eg. opening brace `{` of the function must be on the same line as the declartion `func`
  - In `x+y`, a newline is permitted after but not before the `+` operator
- Variables if not initialized with a value, get assigned a *zero value*. For numeric type it's 0 for strings it's ""


- Map is a reference to the data structure created by `make`. `c := make(map[string]int)`



### Declarations

- Case matters when declaring stuff outside a function (package-level). If upper case then the thing is "exported" and available outisde the package as well
- Four types of declartions:
  - `var`, `const`, `type` and `func`
- File Sturcture
```
<package declaration>

<imports>

<package-level declartions of types, variables, constants and functions>
```
- **Variables**
  - `var` _name_ _type_ = _expression_
    - Either _type_ or _= expression_ can be omitted, but not both
      - `var i = "hello"` - determined by the right side expression
  - Variables declared always take a default meaningful value (_zero value_) to avoid unexpected behaviour
    - `0` for numbers
    - `false` for booleans
    - `nil` for interfaces and reference types like slice, pointer, map, channel, function
  - `var i, j, k int // 0, 0, 0`
  - `var b, f, s = true, 2.3, "four"`
- only withing a function, a *short variable declaration* may be used to initialize and declare a local variable
  - `name := expression` - type of `name` is determined by `expression`
  - Remember `:=` is a declartion and `=` is an assignment
  - if some of the variables on the left-hand side of `:=` are already declared then it acts like an assignment
  - A short variable declartion must declare at least one new variable
    - not valid code:
      ```
      f, err := os.Open(file)
      f, err := oss.Create(ofile) // compile error: no new variables
      ```
- **The `new` Function**
  - `new(T)` creates an unnamed variable of type `T` initializes it with the zero value of T and returns its address, which is of type `*T`
    ```
    p := new(int)   // p, of type *int, points to an unnamed int variable
    fmt.Println(*p) // "0"
    *p=2            // sets the unnamed int to 2
    fmt.Println(*p) // "2"
    ```
- Keeping a note of how garbage collection works is usefull when optimizing performance. When a pointer lives outside a scope and can reference an object
  inside the scope, it still can be reached, hence the garbage collector cannot reclaim the memory allocated for the variable inside the scope. 
  It's good to keep in mind for performance critical programs how the garbage collection works.

- **Scope**
  - important to read **2.7. Scope** of the go book p.48, last para, till the end.


### Basic Types
- **Numeric Types**
  - `int` is either 32 or 64 bit in width depending on the compiler
  - `rune` is synonym for `int32` and indicates that the value is a Unicode code point
  - `byte` is synonym for `uint8`
  - `int` is not as same as `int32` even if it's natural size is 32 bits. An explicit conversion is required where 32 bits int is required
  - `uintptr` enough to hold all the bits of a pointer value
- **Operators**
  - ^ is bitwise XOR when it's used as a binary operator and when used as unary operator (as prefix) it is a bitwise negation or complement
  - &^ operator is bit clear operator (AND NOT, i.e x ∧ ¬Y)

#### Side note (Sets in Binary representation)
- Binary representation of a number can be thought of like a set, where 1 means that the number is in the set. And bitwise
  operations will then correspond to some set operations
  eg:
  ```golang
  var x unint8 = 1<<1 | 1<<5
  var y unint8 = 1<<1 | 1<<2
  
  fmt.Println("%08b\n", x) // "00100010", the set {1, 5}
  fmt.Println("%08b\n", y) // "00000110", the set {1, 2}

  fmt.Println("%08b\n", x&y) // "00000010", the intersection {1}
  fmt.Println("%08b\n", x|y) // "00100110", the union {1, 2, 5}
  fmt.Println("%08b\n", x^y) // "00100100", the symmetric difference {2, 5}
  fmt.Println("%08b\n", x&^y) // "00100000", the difference {5}

  for i := unint(0); i < 8; i++ {
      if x&(1<<i) != 0 {
          fmt.Println(i) // "1", "5"
      }
  }
  fmt.Println("%08b\n", x<<1) // "01000100", the set {2, 6}
  fmt.Println("%08b\n", x>>1) // "00010001", the set {0, 4}
  ```
- **Strings**
  - Strings are immutable. Which means it is safe for two copies of a string to share the same underlying memory; Substring of a string can use the same underlying memory
  ![](./img/202208042026-1.png)
  - Double quoted strings can have excape sequences. Including `\xhh`, `\ooo` -- where ooo is octal digits and max being `\377`, both denoting single byte with the specified value.
  - Raw string literal is written with \`...\` (backticks)
- **Unicdoe**
  - A unicode code point is called a rune in go terminology and is synonym to int32. UTF-32 encoding each code point has the same size 32 bits.
  - In a string literal \uhhhh can be used for 16 bit value of the code point and \Uhhhhhhhh can be used for 32 bit value of the code point. Unicode escapes can also be used in rune literals `'\u4e16'`
  - These are the same (underlying bytes are the same):
    ```
    "世界"
    "\xe4\xb8\x96\xe7\x95\x8c"
    "\u4e16\u754c"
    "\U00004e16\U0000754c"
    ```
  - When decoding strings using utf8.DecodeRuneInString or using range and an invalid byte sequence is encountered, it is replaced with \uFFFD (white question mark)
  - A []rune conversion applied to a UTF-8-encoded string returns the sequence of Unicde code points that the string encodes:
    ```
    s := "プログラム"
    fmt.Printf("% x\n", s) // "e3 83 97 e3 83 ad e3 82 b0 e3 83 a9 e3 83 a0"
    r := []rune(s)
    fmt.Printf("%x\n", r) // "[30d7 30ed 30b0 30e9 30e0]"
    fmt.Println(string(r)) // プログラム
    ```
- **Constants**
  - It is known that constants are evalutated at compile time. Also, since their value is known at compile time, the results of all arithmetic, logical and comparison operations applied to constant operands are themselves constants, as are the results of conversions and calls to certain built in functions such as len, cap, real, imag, complex and unsafe.Sizeof
  - **iota**
    - It's a constant generator. It's value begins at zero and increments by one for each item in the sequence
    - Example from time package
      ```golang
      type Weekday int
      const (
          Sunday Weekday = iota
          Monday
          Tuesday
          Wednesday
          Thursday
          Friday
          Saturday
      )
      ```
    - Example defining constants with bits and using them
      ```golang
      type Flags uint
      const (
         FlagUp Flags = 1 << iota
         FlagBroadcast
         FlagLoopback
         FlagPointToPoint
         FlagMulticast
      )

      func IsUp(v Flags) bool { return v&FlagUp == FlagUp }
      func TurnDown(v *Flags) { *v &^= FlagUp }
      func SetBroadcast(v *Flags) { *v |= FlagBroadcast }
      func IsCast(v Flags) bool { return v&(FlagBroadcast|FlagMulticast) != 0 }

      func main() {
          var v Flags = FlagMulticast | FlagUp
          fmt.Printf("%b %t\n", v, IsUp(v)) // "10001 true"
          TurnDown(&v)
          fmt.Printf("%b %t\n", v, IsUp(v)) // "10000 false"
          SetBroadcast(&v)
          fmt.Printf("%b %t\n", v, IsUp(v)) // "10010 false"
          fmt.Printf("%b %t\n", v, IsCast(v)) // "10010 true"
      }
      ```
    - Example of using iota to define names of powers of 1024
      ```golang
      const (
         _ = 1 << (10 * iota)
         KiB // 1024
         MiB // 1048576
         GiB // 1073741824
         TiB // 1099511627776
         PiB // 1125899906842624
         EiB // 1152921504606846976
         ZiB // 1180591620717411303424
         YiB // 1208925819614629174706176
      )
      ```
  - **untyped constants**
    - untyped constants allows the constant to be used in expressions without worrying about the precision. untyped constants can be very big, the book says you may assume *atleast* 256 bits of precision
    - only constants are untyped and are of 6 flavors:
      1. untyped boolean
      2. untyped integer
      3. untyped rune
      4. untyped floating-point
      5. untyped complex
      6. untyped string
    - When untyped constants are assigend to a variable, the constant is implicitly converted to the type of that variable
    - read section 3.6.2 for more

### Composite Types
- **Arrays**
  - fixed length sequence. The size is a part of it's type: 
    ```golang
    q := [...]int{1, 2, 3}
    fmt.Printf("%T\n", q) // "[3]int"
    ```
    `...` means that the size must be determined by the initializing values. Else you do it like `var q [3]int = [3]int{1, 2, 3}`
  - It is also possible to specify a list of index and value pairs like follows:
    ```golang
    type Currency int
    const (
        USD Currency = iota
        EUR
        GBP
        RMB
    )
    symbol := [...]string{USD: "$", EUR: "9", GBP: "!", RMB: """}
    fmt.Println(RMB, symbol[RMB]) // "3 ""
    ```
    In this form, indices can appear in any order and some may be omitted; as before, unspecified
    values take on the zero value for the element type. For instance,
    ```golang
    r := [...]int{99: -1}
    ```
    defines an array r with 100 elements, all zero except for the last, which has value −1.
  - We can use the `==` to check if all elements of two arrays are equal, but both the array types must be the same (also same size, since size is part of the type)
- **Slices**
  - slices are variable-length sequences. It's closely connected to array and array is it's underlying data structure.
  - declare and initialize a slice:
    ```golang
    mySlice := []string{"One", Two, Three}
    ```
  - It's a lightweight data structure consisting of a `pointer` that points to the first element of an array (might not be the first element of the actual underlying array), a `length` which is the number of elements in the slice and `capacity` which is the number of elements between the start of the slice and the end of the underlying array. Built-in functions `len` and `cap` return those values
  - We can't use `==` to compare two slices. But we can compare two byte slices using `bytes.Equal` function. For other types of slices, we need to do the comparison ourselves
  - zero value of a slice is `nil`
  - The built-in function make creates a slice of a specified element type, length, and capacity. The capacity argument may be omitted, in which case the capacity equals the length.
    ```golang
    make([]T, len)
    make([]T, len, cap) // same as make([]T, cap)[:len]
    ```
    Under the hood, `make` creates an unnamed array variable and returns a slice of it; the array is accessible only through the returned slice. In the first form, the slice is a view of the entire array. In the second, the slice is a view of only the array’s first len elements, but its capacity includes the entire array. The additional elements are set aside for future growth.
  - Slices are more akin to a struct like so:
    ```golang
    type IntSlice struct {
        ptr      *int
        len, cap int
    }
    ```
    and when you pass a slice, you are passing a copy of this slice data-structure. Ofcourse you have access to the underlying array structure which is always a reference (pointer to its location)
  - `append` function
    - built-in append can append items or even slices to an existing slice
      ```golang
      var x []int
      x = append(x, 1)
      x = append(x, 2, 3)
      x = append(x, 4, 5, 6)
      x = append(x, x...)  // append the slice x
      fmt.Println(x) // "[1 2 3 4 5 6 1 2 3 4 5 6]"
      ```
    - we can use a slice as a stack
      ```golang
      stack = append(stack, v)
      top := stack[len(stack)-1]
      stack = stack[:len(stack)-1]
      ```
    - thing to remember about slice is that it's a lightweight data-structure which only keeps track of the it's length, the capacity of it's underlying array and a pointer to that array. And when you use the slice operators (eg slice[:len(slice)-1], etc) you are creating a new slice, which points to the same array. And hence if you do change the underlying array, this reflected on both the slices.
- **Maps**
  - collection of unordered key/value pairs. the map type is written as `map[K]V`. Where `K` are the types of its keys and values. All keys are of the same type and all the values are of the same type. The key type `K` must be comparable using `==`
  - built in `make` can be used to create a map:
    ```golang
    ages := make(map[string]int)
    ```
  - map literal can also be used:
    ```golang
    ages := map[string]int{
        "alice":   31,
        "charlie"  34,
    }
    emptymap := map[string]int{} // initialize an emtpy map
    ```
  - map elements can be deleted:
    ```golang
    delete(ages, "alice)
    ```
  - Even if key is not present it will not throw an error and if you try to do a map lookup using a key that isn't present, it returns the zero type for its type
    ```golang
    age := ages["bob"] // 0
    ```
  - but if we would like to know whether the key was there or not we can do:
    ```golang
    age, ok := ages["bob"]
    if !ok { /* "bob" was not a key in the map. do something */}

    if age, ok := ages["bob"]; !ok { /* ... */ } // shorter way of writing
    ```
  - Map elements cannot be addressed. i.e you can't get their address/pointer
  - Never treat map as ordered. If some sort of ordering is required, then we need to sort keys separately and then access the map:
    ```golang
    import "sort"

    var names []string
    for name := range names{
        names = append(names, name)
    }
    sort.Strings(names)
    for _, name := range names {
        fmt.Printf("%s %d\n", name, ages[name])
    }
    ```
  - map can be `nil` (it is its zero value), i.e there is no reference to a hash table anywhere. Accessing map that is nil causes panic
  - like slices, maps can't be compared using `==`; will need to write a function for it.
  - map can serve the purpose of a set, since keys cannot repeat
  - if you do want to use slices as keys then we can convert them to say string type representation and then use it. Apparently that's a valid thing to do and the author showed an example with slices of string themselves and a function k that maps from a slice to another comparable type (in this case string) like int, bool, string, etc. so that it can be then used as a key of the map
  - The value type of map can itself be a composite type, such as a map or a slice.

- **Structs**
  - structs are simply a collection of types that together form a single entity.
  - Classical example:
    ```golang
    type Employee struct {
        ID         int
        Name       string
        Address    string
        DoB        time.Time
        Position   string
        Salary     int
        ManagerID  int
    }

    var dilbert Employee
    ```
  - You can use dot operator as usual to access the fields. Even if you have the pointer to Employee, you can use the dot operator as usual
  - Field order is significant to type identity. i.e you can't change the order of declaration of the struct and expect it to be the same struct
  - Struct literals:
    ```golang
    type Point struct{ X, Y int}
    p := Point{1, 2}
    ```
  - If all fields of a struct are comparable then the struct itself is comparable. The `==` operation compares the corresponding fields of the two structs in order. The two expressions printed below are equivalent:
    ```golang
    type Point struct{ X, Y int }

    p := Point{1, 2}
    q := Point{2, 1}
    fmt.Println(p.X == q.X && p.Y == q.Y) // false
    fmt.Println(p == q) // false
    ```
  - *Struct Embedding*
    - Go lets us declare field with a type but no name, called *anonymous fields*. The type of the field must be a named type or a pointer to a named type.
    - Embedding a struct refers to including a struct in the definition of a struct and making it an anonymous field.
    - An example of how it is useful. 
      ```golang
      type Point struct{
          X, Y int
      }

      type Circle struct{
          Center Point
          Radius int
      }

      type Wheel struct{
          Circle Circle
          Spokes int      // number of spokes count
      }

      var w Wheel w.Circle.Center.X = 8 w.Circle.Center.Y = 8
      w.Circle.Radius = 4
      w.Spokes = 24
      ```
      as you can see it's quite verbose having to mention each field and subfield. We can instead use anonymous fields like so:
      ```golang
      type Point struct{
          X, Y int
      }

      type Circle struct{
          Point
          Radius int
      }

      type Wheel struct{
          Circle
          Spokes int      // number of spokes count
      }

      var w Wheel
      w.X = 8       //equivalent to w.Circle.Point.X = 8
      w.Y = 8       //equivalent to w.Circle.Point.Y = 8
      w.Radius = 4  //equivalent to w.Cirlce.Radius = 4
      w.Spokes = 24
      ```
      Note that the commented equivalent are still valid.
      Struct literals will still have to mention the field types. Any of the two forms is valid:
      ```golang
      w = Wheel{Cirlce{Point{8, 8}, 5}, 20}

      w = Wheel{
          Circle: Circle{
              Point: Point{X: 8, Y: 8}
              Radius: 5,
          },
          Spokes: 20,
      }

      ```

### 5.3
- bare return is a shorthand way to return each of the named result variables in order
  ```golang
  func CountWords(url string) (words, images int, err error){
      resp, err := http.Get(url)
      if err != nil {
          return
      }
  }

  ```
  `return` above is equivlant to `return words, images, err` and the values of `words` `images` is the default values of the data type. Bare returns should be used sparingly because it isn't instantly obvious what is being returned. On the other hand it reduces verbosity and code reuse.


### 5.4 Errors
- If an error has only one possible cause, the result is a boolean, usually called ok
- `error` is an interface type and an error implies something went wrong and we can get its message by calling its `Error()` method or by printing it `fmt.Println(err)` `fmt.Printf("%v", err)`
- **[My note]** Go's approach with errors is that things can go wrong and programs and libraries should be well written and document what they expect can go wrong. Other than that, "exceptions" are a sort of supported (more on this when I have read it fully), they aren't the primary way of conveying that something can go wrong. First its `error` for "expected" failure and then there are "exceptions" for truly unexpected errors that indicate a bug. With if else, return control flow, go wants programmers to pay more and effor to attention to what could go wrong.

#### 5.4.1 Five ways to handle errors: 
- **[Refer Read]** 5.4.1  Error-Handling Strategies
  1. Propogate upwards and also add information and context to the error message using `fmt.Errorf()`
     Be concise and precise. if `f(x)` encounters error than its
     responsibility is to report attempted operation `f` and the arguments
     `x` as they relate to the error. And errors can be chainged by adding to
     fmt.Errorf(). From function `abc(y)`, If you want to report an error but
     it happend due to another function and you want to propogate it, don't
     just send it off, add more info. - `fmt.Errorf(tried doing xyz on %s:
     %v, y, err)` where err is the error you got from from xyz function,
     because what `xyz`'s err reported, might not make sense to the function
     `abc`'s caller.
   2. Second handlin erros that represent transient problems which are un predictable, with retries-for example retyring an ht      tp connection (read example in the section)
   3. Print error and stop the program gracefully, but this is mostly reserved for the main function to do.
      `log.Fatalf("oh oh %v", err)` is a way to print a fatal log
   4. Some cases it's enough to log the error and continue (perhaps with less functionality) using `fmt.Fprintf(os.Stderr, "")   ` or `log.Printf()`
   5. Most rarely it is okay to ignore a error and move on, but if you do, document the intention clearly


#### 5.7 Variadic Functions

``` golang
  func sum(vals ...int) int{
      total := 0
      for _,val := range vals{
          total += val
      }
      return total
  }

  fmt.Println(sum(1, 2, 3, 4))
  // implicitly makes a slice of the the size of arguments passed.

  // shows how to invoke variadic function when args are already in a slice
  values := []int{1, 2, 3, 4}
  fmt.Println(sum(values...))


  // these are not the same types even though the `...int` parameter behaves lika slice within the function body
  func f(...int) {}
  func g([]int) {}
```
#### 5,8 Deffered function calls
- `defer` prefix before a function call causes the function to be *called* just before the function done with its execution whether it returns, abnormally stops or panics. It is usually written just after acquiring a resource.
- A nice trick to pair "on-entry" and "on-exit" actions using defer
  ```golang
  func bigSlowOperation(){
      defer trace("bigSlowOperation")()
      // ... work
      time.Sleep(10 * time.Second)
  }

  func trace(msg string){
      start := time.Now()
      fmt.Printf("enter %s:", msg)
      return func() { log.Printf("exit %s (%s)", msg, time.Since(start)) }
  }
  ```
  Now since the defer statement needs to be executed, it needs to evaluate `trace("bigSlowOperation")`, because its return value is what is being defered not itself. And because Anonymous functions have access to named variables defined in enclosing function, it can print out the time elapsed since `start`.
- Deffered functions run *after* return statements have update the function's result variables.
- A deferred anonymous function can observe the function's results
  ```golang
  func double(x int)  (result int) {
      defer func() { fmt.Printf("double(%d) = %d\n", x, result) }()
      result x + x
  }
  _ = double(4)
  //
  // "double(4) = 8"
  ```
- Pay more attention to defer statements in loop bodies. A huge amount of resources might open up but may run out of memory and they might never get closed


#### 5.9 Panics
- Usually done by a programmer only for "impossible" situations


#### 5.10

- if the built-in `recover` function is called within a deferred function and the function containing the `defer` statement is panicking, `recover` ends the current state of panic and returns the panic value. If recover is called any other time, it has no effect and returns nil.
```golang
func Parse(input string) (s *Syntax, err error){
    defer func() {
        if p := recover(); p!= nil {
            err = fmt.Errorf("internal error: %v", p)
        }
    }()
    // ..parse
}
```
The deferred function in Parse recovers from a panic, using the panic value to construct an error message.


#### 6.1 Method Declarations
- Methods can be declared to any named typed as long as the underlying type is not a pointer or an interface
  ```golang
  type P *int
  func(P) f() { /* ... */ } //compile error: invalid receiver type 
  ```
- The method has another parameter called the *receiver* which is a legacy term from OOP. 
  ```golang
  type Number int
  func (n Number) Double() int {
      return n*2
  }
  ```
  Here n is the receiver parameter

- `*T` and `T` as receiver types
  To functions, one takes a `Point` type and the other takes `*Point`
  ```golang

  type Point struct{
      X,Y  float64
  }

  func (p Point) Distance(q Point) float 64 {
      return math.Hypot(q.X-p.X, q.Y-p.Y)
  }

  func (p *Point) ScaleBy(factor float64) {
      p.X *= factor
      p.Y *= factor
  }
  ```
  1. Either the receiver argument has the same type as the receiver parameter, Both have type `T` or both have type `*T`:
     ```golang
     p = Point{1, 2}
     pptr = &p
     p.Distance(q) //Point
     pptr.ScaleBy(2) //*Point
     ```
  2. Receiver argument is a variable of type `T` and the receiver parameter has type `*T`
     ```golang
     p.ScaleBy(2) //implicit (&p).ScaleBy()
     ```
     - Note: We cannot call a `*Point` method on a non-addressable `Point` receiver, because there's no way to obtain the address of a temporary value.
     ```golang
     Point{1, 2}.ScaleBy(2) // compile error:  can't take address of Point literal
     ```
  3. Reciever argument has type `*T` and the receiver parameter has type `T`
     ```golang
     pptr.Distance(q) //implicit (*pptr).Distance()
     ```
- *`nil` is a valid receiver value for a method, especially when nil is meaningful zero value of the type, like maps and slices*
- According to convention, if one of the methods defined has a pointer receiver of type `T` then all methods should have the pointer receiver type `T`

#### 6.3 Composing Types by struct Embedding
- **[Read]**
- basically deals with composition in object-orented paradigm. Embedded structs in other struct promote their methods to the struct they are in. Hence the enclosing struct can use its embedded structs mehtods. Just like how when referring to an anonymouse field, we can neglect the struct name itself and go straight to its field. instead `Cirlce.Point.x`  just `Circle.x` is enough
- The methods of Point also get promoted to the struct it is embedded in:
  ```golang
  import "image/color"
  type Point struct{ X, Y float64 }
  type ColoredPoint {
      Point
      Color color.RGBA
  }
  
  var cp ColoredPoint
  cp.X = 1
  fmt.Println(cp.Point.X) // "1"
  cp.Point.Y = 2
  fmt.Println(cp.Y) // "2"

  red := color.RGBA{255, 0, 0, 255}
  blue := color.RGBA{0, 0, 255, 255}
  var p = ColoredPoint{Point{1, 1}, red}
  var q = ColoredPoint{Point{5, 4}, blue}
  fmt.Println(p.Distance(q.Point))
  p.ScaleBy(2)
  q.ScaleBy(2)
  fmt.Println(p.Distance(q.Point)) / "10"
  ```
- An anonymous field can also be a pointer to a named type
  ```golang
  type ColoredPoint struct {
      *Point
      Color color.RGBA
  }
  ```
- a struct can also have more than one anonymous fields:
  ```   golang
  type ColoredPoint struct {
      Point
      color.RGBA
  }
  ```
  In this case `ColoredPoint` will have all the methods of `Point`, all the methods of `RGBA`.

#### 6.4 Method Values and Expressions
- Method values is when you have a method and you assign it to a variable `distanceFromP := p.Distance`; here `p` is of the type `Point`.
- Method expression is when you assign the "static" method to a funciton variable, in that case the first argument to that funciton variable will be the reciever argument. `distance := Point.Distance; fmt.Println(distance(p,q))` or scale which takes a `*Point` reciever. `scale := (*Point).ScaleBy`
  
#### 6.5 Example: Bit vector
- Did all the exercises 6.1 to 6.5
- Learnings
  - `range` returns a copy of the element and not a pointer to it
  - `^` is an xor operation but also a bit complement when used on a single operand
  - slices can only be compared to nil. They can't be compared with other slices to check equality. Arrays on the other hand can be compared.


#### 6.6 Encapsulation
- Go has one mechanism to control visibility of names - Capilaized are exported and uncapitalized or not.
- Same thing controls the fields of a struct or a method of a type.
- Go stype omits redundant prefix for methods like Get, Fetch, Find, Lookup, etc.

  example, the Logger:
  ```golang
  package log

  typer Logger struct {
      flags int
      prefix string
      ...
  }

  func (l *Logger) Flags() int
  func (l *Logger) SetFlags(flag int)
  func (l *Logger) Prefix() int
  func (l *Logger) SetPrefix(prefix string)
  ```

#### 7.1 Interfaces as Contracts
- In golang, a type doesn't have to declare all the interfaces it satisfies. Instead it is *satisfied implicitly*.
- An interface is like a contract. If you can satisfy the methods in an interface, then you have implemented that interface
- Interfaces make the behaviour clear. How you do it, is completly up to the programmer implementing the interface
- Example is `io.Writer` and `Fprintf()`. Fprintf wants a `io.Writer` interface as it's first argument and as long as the argument has the `Write()` method, with the correct signature and behaviour it will call it. It doesn't care whether there is actual writing happening anywhere, it only cares that it can call `Write`
- For example, this is a valid implemenation of the Writer interface:
  ```golang
  type ByteCounter int
  func (c *ByteCounter) Write (p []byte) (int, error) {
      *c += ByteCounter(len(p)) // convert int to ByteCounter
      return len(p), nil
  }

  ```
  and since `ByteCounter` satisfies the `io.Writer` contrace, we can pass it to `Fprintf`
  ```golang
  var c ByteConter
  c.Write([]byte("Hello"))
  fmt.Println(c) // "5", = len("hello")

  c = 0 // reset
  var name = "FooBar"
  fmt.Fprintf(&c, "hello, %s", name)
  fmt.Println(c) // "13" = len("hello, FooBar")
  ```

#### 7.3 Interface satisfaction
- A type satisfies an interface if it possesses all the methods the interface requires.
- Assignability of a interface variable applies if both sides have the mehtods required to satisfy the interface:
  ```golan
  var w io.Writer
  w = os.Stdout // OK: *os.File has Write method
  w = new (bytes.Buffer) // OK: *bytes.Buffer has Write method
  w = time.Second // compile error time.Second lacks Write() method

  var rwc io.ReadWriteCloser
  rwc = os.Stdout // OK
  rwc = new(bytes.Buffer) // compile error: *bytes.Buffer lacks Close mthod

  w = rwc // OK io.ReadWriteCloser has a Write method
  rwc = w // compile error: io.Writer lacks Read and Close method


  // same with the fmt.String interface

  var s Intset
  var _ = s.String() // OK: implicit conversion of s to &s cause *Intset has a String method
  var _ fmt.Stringer = &s // OK
  var _ fmt.Stringer = s // compile error; Intset doesn't have a String method
  ```
- An interface types wraps and conceals the concrete type and it's value. Only the methods revealed by the interface type maybe called even if the concrete type has others:
  ```golang
  os.Stdout.Write([]byte("hello")) // OK
  os.Stdout.Close() // OK
  var w io.Writer
  w = os.Stdout
  w.Write([]byte("hello")) // OK io.Write has a Write method
  w.Close() // compile error. No Close method defined by io.Writer
  ```
- The more methods defined by the interface type, the greater demands are placed on the types that implement it, and the more we know about it's values.
- An empty interface (that which doesn't define any methods) tells us nothing about a type and places no demands on the type that satisfies it.
- At compile time we can have a assertion like so, so that we document the relationship between the interface type and the concrete type. Even though this is not required and interfaces are implicitly satsified by the methods of a type
  ```golang
  //*bytes.Buffer must satsify io.Writer
  var w io.Writer = new(bytes.Buffer)
  //or more frugally

  var _ io.Writer =(*bytes.Buffer)(nil)
  ```

- A pointer to a struct is a common method bearing type. ie. most of the time, these are used to satisfy an interface, but these are not the only ones that can satisfy an interface

#### 7.5 Interface values
- **Note**: "dynamic value" and "dynamic type" mentioned here are conceptual. In implemenation, the are different things
- Dynamic type and value are assigned (conceptually/internally) when we assign a type that satisfies a interface type to it.
  ```golang
  var w io.Write
  // dynamically assigns the type to *os.File and value as an instance of os.File
  w = os.Stdout // implicitly does w = io.Writer(os.Stdout)
  
  ```
  Read the section for more
- Interface values are comparable and can be used as keys of a map or as the operand of a switch statement
- Two interface values are equal if they have identical dynamic type and if their dynamic values are equal occording to usual behaviour of `==` for the type. If the type is non-comparable, there is a panic:
  ```golang
  var x interface{} = []int{1,2,3}
  fmt.Println(x == x) // panic: comparing uncomparable type []int
  ```
- Only compare interface values if you are certain that they contain dynamic values of comparable types
- We can use `%T` of fmt to report dynamic type of the interface value:
  ```golang
  var w io.Writer
  fmt.Printf("%T\n", w) // "nil"

  w = os.Stdout
  fmt.Printf("%T\n", w) // *os.File
  ```
- **7.5.1 Caveat: An interface containing a nil pointer is non-nil**
  - **Read seciton**
  - If the interface's dynamic type is set to something and the value is nil, the interface variable as a whole is not `nil`, or rather it's value is non-nil (not dynamic value, but its value)
  - **Remember** - a nil pointer does still have a type:
    ```golang
    var w io.Writer
    var b *bytes.Buffer
    w = b // Ok, but the dynamic type is set to *bytes.Buffer and the value is nil.
    w.Write([]bytes("hello"))  // will raise compile error. You can still call Write() method on it and it will call the (*bytes.Buffer) Write() method. and the reciever argument will be nil
    w == nil // False since it has a dynamic type of *bytes.Buffer 
    ```

#### 7.7 
- Functions can also satisfy an interface and usually these are adapter types whose the sole method and the function itself have the same signature and the job of the method is to just call the function
  ```golang
  type HandlerFunc func (w ResponseWriter, r *Request)

  func (f HandlerFunc) ServeHTTP(w ResponseWriter, r *Request) {
      f(w, r)
  }
  ```
  Here, the type `HandlerFunc` satisfies the interface of `http.Handler`, we can now use this function type anywhere where http.Handler interface type is expected


- This trick of functions satisfying an interface allows any other type (such as a struct) to satisfy the interface several different ways.
- Example:
  ```golang
  func main() {
      db := database{"shoes": 50, "socks": 5}
      mux := http.NewServeMux()
      mux.Handle("/list", http.HandlerFunc(db.list)) // type conversion
      mux.Handle("/price", http.HandlerFunc(db.price)) // type conversion
      log.Fatal(http.ListenAndServe("localhost:8000", mux))
  }
  type dollars float64

  type database map[string]dollars

  func (db database) list (w http.ResponseWriter, req *http.Request) {
      for item, price := range db {
          fmt.Fprintf(w, %s: %s\n, item, price)

      }
  }

  func  (db database) price (w http.ResponseWriter, req *http.Request) {
      item := req.URL.Query().Get("item")
      price, ok := db[item]
      if !ok {
          w.WriteHeader(http.StatusNotFound)
          fmt.Fprintf(w, "no such item")
          return
      }
      fmt.Fprintf(w, "%s", price)
  }
  ```

#### 7.8 `error` Interface

-  errors package is simple
  ```golang
  package errors
  
  func New(text string) error { return &errorString{text} }
  type errorString struct {text string}
  func (e *errorString) Error() string {return e.text}
  ```
- Pointer type `*errorString` not `errorString` satisfies the interface becase every call to `New` must allocate a distince error instance. We not want distinguished error such as io.EOF to compare equal to one that merely happend to have the same message.
- A nice example of Errno is also given. It satisfies the error interface too, but it's `Error` method also does a lookup for the error no -> error message of the operating system. depedning on the error number, we get different error messages
- 
  ```golang
  var err error = syscall.Errno(2)
  fmt.Println(err.Error())
  fmt.Println(err)
  ```
  The interface value (err) holds the `type` as syscall.Errno and it's value is `2`

#### 7.9 Expression Evaluator
- Goes through the process of defining a generic expression evaluator using an interface type: 
  ```golang
  type Var string
  type Env map[Var] float64
  type Expr interface {
      //Eval returns the value of this Expr in the environment env
      Eval (env Env) float64
      //Check reports errors in this Expr and adds its Vars to the Set
      Check (vars map[Var]bool) error
  }
  ```
  Several types of expression are implemented using this.. A Var itself is expression which evaluates to the value of the variable x in the env. And literal just returns it's value, while binary, unary and call (function call) expressions do some evaluation on their arguments. Their arguments and the operation they perform are stored as field values in their structs. Remeber structs are mostly used to satisfy an interface. The section also goes through the testing process in golang briefly. The seciton introduces how one would test something like the expression evaluator very beautifuly.


#### 7.10 Type Assertions

- `x.(T)`. `x` is an expression of an interface type and `T` is a type.
- If the asserted type `T` is a concrete type:
  ```golang
  var w io.Writer
  w = os.Stdout (w: dynamic type = *os.File; dynamic value = os.Stdout)
  f := w.(*os.File) // success: f == os.Stdout (extracted the concrete value of the concrete type)
  c := w.(*bytes.Buffer) // panic: interface w holds *os.File not *bytes.Buffer
  ```
- If the asserted type `T` is an interface type. It change the type of the expression, making a different (and usually larger p set of methods accessible, but it preserves the dynamic type and value components inside the interface value
  ```golang
  var w io.Writer
  w = os.Stdout
  rw := w.(io.ReadWriter) // success: *os.File has both Read and Write
  w = new(ByteCounter)  // Has write method
  rw = w.(io.ReadWriter) // panic: *ByteCounter doesn't have a Read method
  ```
- we can use a second variable to capture whether assertion succeeded or not:
  ```golang
  var w io.Writer = os.Stdout
  f, ok := w.(*os.File) // f == os.Stdout
  b, ok := w.(*bytes.Buffer) // failure: !ok, b == nil
  ```
- usually used in an if statement like this:
  ```golang
  if w, ok := w.(*os.File); ok {
      // ... use w
  }
  ```
 
#### 7.11 Discriminating errors with type assertions
- just goes through how some packages use the type assertions to discriminate the errors and handle them separately

#### 7.12 Querying behaviors with interface type assertions
-  we can use type assertion to other interfaces to see if the dynamic type of an interface also satisfies the other interface
- some io.Writers also have a `WriteString()` method that write a string more efficiently (without making a copy somehow)
   ```golang
   // writeString writes s to w
   // If w has a WriteString method, it is invoked instead of w.Write
   func writeString(w io.Writer, s string) (n int, err error) {
       type stringWriter interface {
           WriteString(string) (n int, err error)
       }
       if sw, ok := w.(stringWriter); ok {
           return sw.WriteString(s) // avoid a copy
       }

       return w.Write([]byte(s)) //allocate temp copy
   }
   func writeHeader(w io.Writer, contentType string) error {
       if _, err := writeString(w, "Content-Type: "); err != nil {
           return err
       }
       if _, err := writeString(w, contentType); err != nil {
           erturn err
       }
   }

   ```
- The `writeString` function above uses a type assertion to see whether a value of a general interface type also satisfies a more specific interface type, and if so, it uses the behavior s of the specific interface. This technique can be put to good use whether or not the queried interface is standard like `io.ReadWriter` or user-define d like `stringWriter`.

#### 7.13 Type Switches
- There are two ways of using interfaces. One described above where we have a type that satisfies an interface by implemeting it's methods. The emphasis is on the methods (Does the type have that particular method?). If they do have the method, then they are "similar"
- The second way of using interfaces is by using the fact that interface values can hold variety of concrete types. So we can use type assertions to see what type the interface value is holding at the moment. This use of interfaces is called "discriminated union"
- An example used is of the `sql.DB.Exec()` which takes any type and forms a valid sql query string
  ```golang
  import "database/sql"

  func listTracks(db sql.DB, artist string, minYear, maxYear, int) {
      resutl, err := db.Exec(
        "SELECT * FORM tracks WHERE artist = ? AND ? <= year AND year <= ?", atist, minYear, maxYear)
      )
  }
  ```
  The `func sqlQuote(x interface{}) string` does that using type switches: 


  ```golang
  func sqlQuote(x interface{}) string {
      switch x := x.(type) {
          case nil: return "NULL"
          case int, uint:
            reuturn fmt.Sprintf("%d", x) // x has type interface{} here
          case bool:
            if x {
                return "TRUE"
            }
            return "FALSE"
          case string:
            return sqlQuoteString(x) 
          default:
            panic(fmt.Sprintf("unexpected type %%: %v", x, x)
      }
  }
  ```
  The new variable is also called `x`. like a switch statement a type switch implicitly creates a lexical block, so a declaration of a new variable doesn't conflict with outer block. Each case also creates a new lexical block.

- In a single-type case, the type is the same as in the case. In all other cases `x` has an interface type (like in `case int, uint:` above.
- There are no fall through allowed


#### 7.14 Example: Token-based xml decoding


#### 7.15 A few Words of advice
- When makeing interfaces, don't make an interface such that it's satisfied by only one type. You can always use export mechanism to hide the methods you don't want of the type to be accessed. 
- The exception to this is when you have to have a concrete type to satisfy an interface, but that type can't live in the same package. This way interfaces is used to decouple two packages.
- A good rule of thumb for interface design is *ask only for what you need*. That is is why most of the time, interfaces are small, defining one or two methods only.


