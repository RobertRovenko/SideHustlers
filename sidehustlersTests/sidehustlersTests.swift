//
//  sidehustlersTests.swift
//  sidehustlersTests
//
//  Created by Robert Falkbäck on 2023-10-14.
//

import XCTest
@testable import sidehustlers
import SwiftUI

final class sidehustlersTests: XCTestCase {

    override func setUpWithError() throws {
           // Put setup code here. This method is called before the invocation of each test method in the class.
       }


    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testClearFields() {
            // Arrange
            var postView = PostView(selectedTab: .constant(0))

            // Act
            postView.clearFields()

            // Assert
            XCTAssert(postView.exposedTitleText.isEmpty)
            XCTAssert(postView.exposedDescriptionText.isEmpty)
            XCTAssertEqual(postView.exposedChore.reward, 0)
        }
    
    func testAddChore() {
           // Arrange
           let viewModel = ChoreViewModel()
           let expectation = XCTestExpectation(description: "Chore added successfully")

           let testChore = Chore(id: "", title: "Test Chore", description: "This is a test chore", reward: 10, createdBy: "test@example.com", author: "testUID", location: (latitude: 0.0, longitude: 0.0))

           // Act
           viewModel.addChore(chore: testChore, createdBy: "test@example.com") { documentID in
               // Assert
               XCTAssertNotNil(documentID, "Chore should be added with a valid document ID")
               expectation.fulfill()
           }

           wait(for: [expectation], timeout: 5.0) // Adjust timeout as needed
       }
 
    func testMessagesViewTest() {
        // Arrange
        let selectedTab = Binding.constant(0)
        let messageManager = MessageManager()
        let messagesView = MessagesView(selectedTab: selectedTab, messageManager: messageManager)

        // Act
        // Perform any actions or interactions that you want to test here.
        messagesView.onAppear()

        // Assert
        // Add assertions based on the expected behavior of MessagesView and the interactions with the mock MessageManager.
        XCTAssertNoThrow(messageManager.loadMessagesAndContacts())

      
    }

    
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}

