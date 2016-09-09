//
//  ArrayExtensions.swift
//  EZSwiftExtensions
//
//  Created by Goktug Yilmaz on 15/07/15.
//  Copyright (c) 2015 Goktug Yilmaz. All rights reserved.
//
import UIKit

extension Array {
    /// EZSE: Returns a random element from the array.
    public func random() -> Element? {
        guard self.count > 0 else {
            return nil
        }

        let index = Int(arc4random_uniform(UInt32(self.count)))
        return self[index]
    }

    /// EZSE: Checks if array contains at least 1 instance of the given object type
    public func containsInstanceOf<T>(object: T) -> Bool {
        for item in self {
            if item.dynamicType == object.dynamicType {
                return true
            }
        }
        return false
    }

    /// EZSE: Checks if test returns true for all the elements in self
    public func testAll(test: (Element) -> Bool) -> Bool {
        for item in self {
            if !test(item) {
                return false
            }
        }
        return true
    }

    /// EZSE: Checks if all elements in the array are true of false
    public func testIfAllIs(condition: Bool) -> Bool {
        for item in self {
            guard let item = item as? Bool else { return false }

            if item != condition {
                return false
            }
        }
        return true
    }

    /// EZSE: Gets the object at the specified index, if it exists.
    public func get(index: Int) -> Element? {
        return index >= 0 && index < count ? self[index] : nil
    }

    /// EZSE: Reverse the given index. i.g.: reverseIndex(2) would be 2 to the last
    public func reverseIndex(index: Int) -> Int {
        return Swift.max(self.count - 1 - index, 0)
    }

    /// EZSE: Returns an array with the given number as the max number of elements.
    public func takeMax(n: Int) -> Array {
        return Array(self[0..<Swift.max(0, Swift.min(n, count))])
    }

    /// EZSE: Iterates on each element of the array.
    @available(*, deprecated=1.6)
    public func each(call: (Element) -> ()) {
        for item in self {
            call(item)
        }
    }

    /// EZSE: Iterates on each element of the array with its index.
    @available(*, deprecated=1.6, renamed="forEach")
    public func each(call: (Int, Element) -> ()) {
        for (index, item) in self.enumerate() {
            call(index, item)
        }
    }

    /// EZSE: Iterates on each element of the array with its index.
    public func forEach(call: (Int, Element) -> ()) {
        for (index, item) in self.enumerate() {
            call(index, item)
        }
    }

    /// EZSE: Creates an array with values generated by running each value of self
    /// through the mapFunction and discarding nil return values.
    @available(*, deprecated=1.6, renamed="flatMap")
    public func mapFilter<V>(mapFunction map: (Element) -> (V)?) -> [V] {
        var mapped = [V]()
        forEach { (value: Element) -> Void in
            if let mappedValue = map(value) {
                mapped.append(mappedValue)
            }
        }
        return mapped
    }

    /// EZSE: Prepends an object to the array.
    public mutating func insertAsFirst(newElement: Element) {
        insert(newElement, atIndex: 0)
    }

    /// EZSE: Shuffles the array in-place using the Fisher-Yates-Durstenfeld algorithm.
    public mutating func shuffle() {
        var j: Int

        for i in 0..<(self.count-2) {
            j = Int(arc4random_uniform(UInt32(self.count - i)))
            if i != i+j { swap(&self[i], &self[i+j]) }
        }
    }

    /// EZSE: Decompose an array to a tuple with first element and the rest; useful in Functional Programming
    public func decompose() -> (head: Generator.Element, tail: SubSequence)? {
        return (count > 0) ? (self[0], self[1..<count]) : nil
    }

}

extension Array where Element: Equatable {

    /// EZSE: Returns the indexes of the object
    public func indexesOf(object: Element) -> [Int] {
        var indexes = [Int]()
        for index in 0..<self.count {
            if self[index] == object {
                indexes.append(index)
            }
        }
        return indexes
    }

    /// EZSE: Returns the last index of the object
    public func lastIndexOf(object: Element) -> Int? {
        return indexesOf(object).last
    }

    /// EZSE: Checks if self contains a list of items.
    public func contains(items: Element...) -> Bool {
        return items.testAll { self.indexOf($0) >= 0 }
    }

    /// EZSE: Difference of self and the input arrays.
    public func difference(values: [Element]...) -> [Element] {
        var result = [Element]()
        elements: for element in self {
            for value in values {
                //  if a value is in both self and one of the values arrays
                //  jump to the next iteration of the outer loop
                if value.contains(element) {
                    continue elements
                }
            }
            //  element it's only in self
            result.append(element)
        }
        return result
    }

    /// EZSE: Intersection of self and the input arrays.
    public func intersection(values: [Element]...) -> Array {
        var result = self
        var intersection = Array()

        for (i, value) in values.enumerate() {
            //  the intersection is computed by intersecting a couple per loop:
            //  self n values[0], (self n values[0]) n values[1], ...
            if i > 0 {
                result = intersection
                intersection = Array()
            }

            //  find common elements and save them in first set
            //  to intersect in the next loop
            value.forEach { (item: Element) -> Void in
                if result.contains(item) {
                    intersection.append(item)
                }
            }
        }
        return intersection
    }

    /// EZSE: Union of self and the input arrays.
    public func union(values: [Element]...) -> Array {
        var result = self
        for array in values {
            for value in array {
                if !result.contains(value) {
                    result.append(value)
                }
            }
        }
        return result
    }

    /// EZSE: Removes the first given object
    public mutating func removeObject(object: Element) {
        if let index = self.indexOf(object) {
            self.removeAtIndex(index)
        }
    }

    /// EZSE: Removes all occurrences of the given object
    public mutating func removeObjects(object: Element) {
        for i in self.indexesOf(object).reverse() {
            self.removeAtIndex(i)
        }
    }

    /// EZSE: Checks if the main array contains the parameter array
    public func containsArray(lookFor: [Element]) -> Bool {
        for item in lookFor {
            if self.contains(item) == false {
                return false
            }
        }
        return true
    }
}

public func ==<T: Equatable>(lhs: [T]?, rhs: [T]?) -> Bool {
    switch (lhs, rhs) {
    case (.Some(let lhs), .Some(let rhs)):
        return lhs == rhs
    case (.None, .None):
        return true
    default:
        return false
    }
}