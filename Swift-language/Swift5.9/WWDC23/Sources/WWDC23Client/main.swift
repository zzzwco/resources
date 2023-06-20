import WWDC23

let a = 17
let b = 25

let (result, code) = #stringify(a + b)

print("The value \(result) was produced by the code \"\(code)\"")

let e = #email("zzzwco@outlook.com")
print(e)
