//
//  Simple.swift
//  WALL-E
//
//  Created by Tangent on 2018/4/22.
//  Copyright © 2018 Tangent. All rights reserved.
//

import Foundation

func flip<A, B, C>(_ f: @escaping (A) -> (B) -> C) -> (B) -> (A) -> C {
    return { b in { a in f(a)(b) } }
}

func flip<A, B>(_ f: @escaping (A) -> () -> B) -> () -> (A) -> B {
    return { { a in f(a)() } }
}

func flip<A, B>(_ f: @escaping () -> (A) -> B) -> (A) -> () -> B {
    return { a in { f()(a) }}
}

func const<A, B>(_ v: B) -> (A) -> B {
    return { _ in v }
}

func const<A, B>(_ v: @escaping () -> B) -> (A) -> B {
    return { _ in v() }
}

// Tuple
func first<A, B>(_ tuple: (A, B)) -> A { return tuple.0 }
func second<A, B>(_ tuple: (A, B)) -> B { return tuple.1 }
func double<T>(_ value: T) -> (T, T) { return (value, value) }
func triple<T>(_ value: T) -> (T, T, T) { return (value, value, value) }

// Composition & Applicative
func <<< <A, B, C>(lhs: @escaping (B) -> C, rhs: @escaping (A) -> B) -> (A) -> C {
    return { lhs(rhs($0)) }
}

func >>> <A, B, C>(lhs: @escaping (A) -> B, rhs: @escaping (B) -> C) -> (A) -> C {
    return { rhs(lhs($0)) }
}
