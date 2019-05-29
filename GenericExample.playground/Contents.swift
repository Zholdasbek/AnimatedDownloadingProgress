import UIKit

var stringArray = ["Hi","Hello","Good morning"]
var intArray = [1,2,3,4,5]
var doubleArray = [1.2,2.3,3.4]



func printElementFromArray<T>(a: [T]){
    for element in a{
        print(element)
    }
}

printElementFromArray(a: stringArray)
printElementFromArray(a: doubleArray)
printElementFromArray(a: intArray)


//Generic Ex:2


