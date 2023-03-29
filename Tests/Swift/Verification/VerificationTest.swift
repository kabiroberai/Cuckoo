//
//  VerificationTest.swift
//  Cuckoo
//
//  Created by Filip Dolnik on 04.07.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import XCTest
import Cuckoo

class VerificationTest: XCTestCase {
    func testVerify() {
        let mock = MockTestedClass()
        stub(mock) { mock in
            when(mock.noReturn()).thenDoNothing()
        }
        
        mock.noReturn()
        
        verify(mock).noReturn()
    }

    func testVerifyWithCallMatcher() {
        let mock = MockTestedClass()
        stub(mock) { mock in
            when(mock.noReturn()).thenDoNothing()
        }
        
        mock.noReturn()
        mock.noReturn()
        
        verify(mock, times(2)).noReturn()
    }

    func testVerifyWithMultipleDifferentCalls() {
        let mock = MockTestedClass()
        stub(mock) { mock in
            when(mock.noReturn()).thenDoNothing()
            when(mock.count(characters: anyString())).thenReturn(1)
        }

        _ = mock.count(characters: "a")
        mock.noReturn()

        verify(mock).noReturn()
        verify(mock).count(characters: anyString())
    }

    func testVerifyWithGenericReturn() {
        let mock = MockGenericMethodClass<String>()
        stub(mock) { mock in
            when(mock.genericReturn(any())).thenReturn("")
        }

        let _: String? = mock.genericReturn("Foo")

        verify(mock).genericReturn(equal(to: "Foo")).with(returnType: String?.self)
    }

    func testVerifyNext() {
        let mock = MockTestedClass()
        stub(mock) { mock in
            when(mock.readOnlyProperty).get.thenReturn("hi")
            when(mock.count(characters: "a")).thenReturn(1)
            when(mock.count(characters: "b")).thenReturn(2)
        }

        XCTAssertEqual(mock.count(characters: "a"), 1)
        XCTAssertEqual(mock.readOnlyProperty, "hi")
        XCTAssertEqual(mock.count(characters: "b"), 2)

        verifyNext(mock).count(characters: "a")

        let error = TestUtils.catchCuckooFail {
            verifyNext(mock).count(characters: "b")
        }
        XCTAssertEqual(error, "Wanted 1 times but found other calls preceding it.")

        verifyNext(mock).readOnlyProperty.get()
    }
}
