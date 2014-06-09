//////////////////////////////////////////////////////////////////////////////
// Swift Example Code
//  some of it from the WWDC talks
//  some of my own little morsels
//  just trying the language out...
//////////////////////////////////////////////////////////////////////////////

import Cocoa
import libkern

//////////////////////////////////////////////////////////////////////////////
// hello world
//////////////////////////////////////////////////////////////////////////////

var str = "Hello, playground"

//////////////////////////////////////////////////////////////////////////////
// unicode varnames
//////////////////////////////////////////////////////////////////////////////

var π = 3.14159;
π*2
cos(π)

//////////////////////////////////////////////////////////////////////////////
// range based for
//////////////////////////////////////////////////////////////////////////////

for i in 0.0..10.0
{
    var j = sin(0.1*i)
    var k = sin(0.2*i)
    var m = sin(0.3*i)
    let c = NSColor(calibratedRed: j,green: k,blue: m,alpha: 1.0)
}

//////////////////////////////////////////////////////////////////////////////
// stringutils (path extraction)
//////////////////////////////////////////////////////////////////////////////

var a = "http://www.tweakoz.com"
let c = a.pathComponents

//////////////////////////////////////////////////////////////////////////////
// arrays
//////////////////////////////////////////////////////////////////////////////

var ary = ["100",1,"3",2.0]
let rang = 1..100
let r = Array<Int>(rang)

//////////////////////////////////////////////////////////////////////////////
// maps
//////////////////////////////////////////////////////////////////////////////

var dic = ["100":2, "200":2]

for (k,v) in dic
{
    var a = k
    var a2 = v
}

var oh: Int? = dic["100"]

if let item = oh {
  var res = oh.description
  println( res )
}
  
//////////////////////////////////////////////////////////////////////////////
// ternary op
//////////////////////////////////////////////////////////////////////////////

var b = false

var d = b ? 1 : 2

d.description

//////////////////////////////////////////////////////////////////////////////
// pattern matching
//////////////////////////////////////////////////////////////////////////////

let color = (1.0,0.5,0.5,1.0)

switch color {
    
 case (1.0,0.4..0.6,0.3..0.7,1.0):
  print( "yo\n" )
 default:
  println( "dude" )

}

//////////////////////////////////////////////////////////////////////////////
// built-in generics
//////////////////////////////////////////////////////////////////////////////

let names = ["what", "up", "yo"]
println( "names: \(names)" )
names.sort { $0<$1 }
println( "names: \(names)" )

let n2 = names.filter { countElements($0)>2 }
print( "n2: "); println( n2 )

let m2 = names.map { ($0).uppercaseString }
print( "m2: "); println( m2 )

//let r2 = names.reduce(0) { $0 + $1 }
//print( "r2: "); println( r2 )

//////////////////////////////////////////////////////////////////////////////
// GCD / Concurrency
//////////////////////////////////////////////////////////////////////////////

var Blocker = true

let concur_q = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0)
//let serial_q = dispatch_get_main_queue()

dispatch_async( concur_q, { print( "what up yo, from a gcd q (async)\n") } )
dispatch_sync( concur_q, { print( "what up yo, from a gcd q (sync)\n") } )

let in_2_secs = dispatch_time(DISPATCH_TIME_NOW,Int64(NSEC_PER_SEC)*2)
dispatch_after( in_2_secs, concur_q, { Blocker=false } )

var atom = Int64(1)
var patom: CMutablePointer<Int64> = &atom;

let increment = { 
    patom.withUnsafePointer(
    {   p in 
        OSAtomicIncrement64(p)
    })
}
increment()

for i in 1..65536
{
    //dispatch_async( concur_q, increment )
}

print( "atom<\(atom)> (post atomic increment)\n")

//////////////////////////////////////////////////////////////////////////////
// custom generics/templates
//////////////////////////////////////////////////////////////////////////////

func thru<T>(val: T) -> T
{
	return val;
}

func findInArray<T:Equatable>( needle: T,  haystack: Array<T> ) -> Int?
{
	for i in 0..haystack.count
	{
		if haystack[i] == needle { return i }
	}
	return nil
}

//func fibonacci( n : Int ) -> Int { return n<2 ? n : fibonacci(n-1) + fibonacci(n-2) }

//let ϕ = Double(fibonacci(45))/Double(fibonacci(44))

func memoize<T: Hashable, U>( body: ((T)->U, T)->U ) -> (T)->U 
{
    var memo = Dictionary<T,U>()
    var result: ((T)->U)!
    result = { x in 
        if let q = memo[x] { return q }
        let r = body(result,x)
        memo[x] = r
        return r
    }
    return result
}

let factorial_memo = memoize { factorial, n in n == 0 ? 1 : n * factorial(n-1) }
//let fibonacci = memoize { fibonacci, n in n<2 ? Double(n) : fibonacci(n-1) + fibonacci(n-2) }

//    n<2 ? Double(n) : fibonacci(n-1) + fibonacci(n-2)
//}

//println( "fib<7> = \(fibonacci(7))" )
//println( "ϕ = \(ϕ)")

println( "factorial_memo<5> : \(factorial_memo(5))" )
//println( "fibonacci<4> : \(fibonacci(4))" )

struct Stack<T> {

    init() { items = Array<T>()}


    mutating func push(x:T) { items += x }
    mutating func pop() -> T { return items.removeLast() }
    var items: Array<T>
}

struct StackGenerator<T> : Generator
{
    typealias Element = T

    init( _ i: Slice<T> ) { items=i }

    mutating func next() -> T? 
    {
        if items.isEmpty { return nil }
        let ret = items[0]
        items = items[1..items.count]
        return ret
    }

    var items: Slice<T>    
}

extension Stack : Sequence {
    func generate() -> StackGenerator<T> { return StackGenerator( items[0..items.count] ) }
}

var int_stack = Stack<Int>()

int_stack.push(42)
int_stack.push(7)

for i in int_stack {
    println( "test_stack item<\(i)>" )
}

var test_stack = int_stack.pop()

println( "test_stack<\(test_stack)>")

//////////////////////////////////////////////////////////////////////////////
// the adventure game thingie...
//////////////////////////////////////////////////////////////////////////////

class Thing
{
    var type: String { return "Thing" }

    var name: String
    var longdes: String
    
    init( _ name: String, _ longdes: String = "" )
    {
        self.name = name
        self.longdes = longdes
    }

    var desc_deco: String { return "a " + type }
    
}

//////////////////////////////////////////////////////////////////////////////

var t1 = Thing("thing_one")
var as_str = "looking at \(t1.desc_deco)"
println( as_str )

//////////////////////////////////////////////////////////////////////////////

class Link 
{
    init( _ p : Place ) { par=p; dst=nil }

    var par : Place
    var dst : Place?

}

//////////////////////////////////////////////////////////////////////////////

class Place : Thing
{
    override var type: String { return "Place" }
    
    enum Direction { case North,South,East,West }

    typealias place_dict_t = Dictionary<Direction,Link>
    
    var exits: place_dict_t
    
    init(_ name: String, _ longdes: String )
    {
        self.exits = place_dict_t()
        super.init(name,longdes)
    }
    subscript( dir: Direction) -> Link // operator[]
    {
        get {

            if let l = exits[dir]
            {
                return l;
            }
            
            var l = Link(self)
            exits[dir]=l

            return l
        }
    }

}

//////////////////////////////////////////////////////////////////////////////
// custom operators can be defined with / = - + * % < > ! & | ^ . ~
//////////////////////////////////////////////////////////////////////////////

operator infix <-> {  }
operator infix --> {  }
func <-> (l: Link, r: Link ) 
{
    l.dst = r.par
    r.dst = l.par
}
func --> (l: Link, r: Place )
{
    l.dst = r
}

//////////////////////////////////////////////////////////////////////////////

let p1 = Place( "The Dungeon",
    "You're standing in a dungeon, it reeks of human filth. Luckily you are not locked inside." )

let p2 = Place( "The Gate",
    "You are at the exit gate of a large dungeon. There is definitely something wrong with this place." )

let p3 = Place( "The royal buttery",
    "Butter is made here. Moar butter please... " )

p1[.South] --> p2
p2[.East] --> p3
p1[.East] <-> p3[.South]

//////////////////////////////////////////////////////////////////////////////
// more operators
//////////////////////////////////////////////////////////////////////////////

struct v2d { 
    var x=0.0, y=0.0 
    init( _ x: Double, _ y: Double ) { self.x = x; self.y = y }
}
@infix func + (l: v2d, r: v2d) -> v2d { return v2d(l.x+r.x, l.y+r.y) }
@prefix func - (v: v2d) -> v2d { return v2d( -v.x, -v.y) }
@assignment func += (inout l: v2d, r: v2d ) { l=l+r }
@infix func == (l: v2d, r: v2d) -> Bool { return (l.x==r.x) && (l.y==r.y) }

operator prefix +++ {}

var va = v2d(1.0, 2.0)+v2d(3.0,4.0)

//////////////////////////////////////////////////////////////////////////////
// extensions 
//////////////////////////////////////////////////////////////////////////////

class OutputStream {}
class InputStream {}

protocol Serdesable
{
    func serialize(ostream: OutputStream)
    func deserialize(istream: InputStream)
}

extension Thing: Serdesable
{
    func serialize(ostream: OutputStream)
    {
        
    }
    func deserialize(istream: InputStream)
    {
        
    }
}

//////////////////////////////////////////////////////////////////////////////

println( thru(p1) )

print( "Waiting for Blocker....\n")
while Blocker
{
    usleep(1<<20)
}
print( "Blocker unblocked...\n")
