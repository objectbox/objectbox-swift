//
// Copyright © 2020 ObjectBox Ltd. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import XCTest

import ObjectBox

class ManyToManyTests: XCTestCase {

    var store: Store!
    var teacherBox: Box<Teacher>!
    var studentBox: Box<Student>!

    let teacher1 = Teacher(name: "Yoda")
    let teacher2 = Teacher(name: "Dumbledore")

    let student1 = Student(name: "Alice")
    let student2 = Student(name: "Bob")
    let student3 = Student(name: "Claire")

    override func setUpWithError() throws {
        continueAfterFailure = false
        let directoryPath = StoreHelper.newTemporaryDirectory().path
        try store = Store(directoryPath: directoryPath)
        teacherBox = store!.box(for: Teacher.self)
        studentBox = store!.box(for: Student.self)
    }

    override func tearDownWithError() throws {
        try store.closeAndDeleteAllFiles()
    }

    private func putTeachersAndStudents() throws {
        try store.runInTransaction {
            try teacherBox.put([teacher1, teacher2])

            // advance student IDs by 2 to avoid overlap with teacher IDs
            try studentBox.put([Student(name: "Temp1"), Student(name: "Temp2")])
            try studentBox.removeAll()

            try studentBox.put([student1, student2, student3])
        }
    }

    func testManyToMany_applyToDb_notPutYet() throws {
        // No changes, no cry
        try teacher1.students.applyToDb()
        try student3.teachers.applyToDb()

        teacher1.students.append(student1)
        XCTAssertThrowsError(try teacher1.students.applyToDb())

        student3.teachers.append(teacher2)
        XCTAssertThrowsError(try student3.teachers.applyToDb())
    }

    func testManyToMany_applyToDb_empty() throws {
        try teacherBox.put(teacher1)
        try teacher1.students.applyToDb()

        try studentBox.put(student3)
        try student3.teachers.applyToDb()
    }

    func testManyToMany_applyToDb_newObjects() throws {
        try teacherBox.put(teacher1)
        teacher1.students.append(contentsOf: [student1, student2])
        teacher1.students.removeFirst()

        try teacher1.students.applyToDb()
        
        teacher1.students.reset()
        XCTAssertEqual(teacher1.students.count, 1)
        XCTAssertEqual(teacher1.students[0].name, student2.name)
    }

    func testManyToMany_backlink_applyToDb_newObjects() throws {
        try studentBox.put(student1)
        student1.teachers.append(teacher1)
        student1.teachers.append(teacher2)
        student1.teachers.removeFirst()

        try student1.teachers.applyToDb()

        student1.teachers.reset()
        XCTAssertEqual(student1.teachers.count, 1)
        XCTAssertEqual(student1.teachers[0].name, teacher2.name)
    }

    func testManyToMany_appendRemoveAndApply() throws {
        try putTeachersAndStudents()

        teacher1.students.append(student1)
        XCTAssertEqual(teacher1.students.count, 1)
        teacher1.students.append(student2)
        XCTAssertEqual(teacher1.students.count, 2)
        teacher1.students.append(student3)
        XCTAssertEqual(teacher1.students.count, 3)

        teacher1.students.remove(at: 1)
        XCTAssertEqual(teacher1.students.count, 2)

        try teacher1.students.applyToDb()
        teacher1.students.reset()
        XCTAssertEqual(teacher1.students.count, 2)

        let yoda = try teacherBox.get(teacher1.id)!
        XCTAssertEqual(yoda.students.count, 2)
    }

    func testManyToMany_appendAndApply() throws {
        try putTeachersAndStudents()

        teacher1.students.append(student1)
        XCTAssertEqual(teacher1.students.count, 1)

        try teacher1.students.applyToDb()

        teacher1.students.reset()
        teacher1.students.append(student3)
        XCTAssertEqual(teacher1.students.count, 2)
        try teacher1.students.applyToDb()

        teacher1.students.append(student2)
        teacher1.students.reset()
        XCTAssertEqual(teacher1.students.count, 2)

        let yoda = try teacherBox.get(teacher1.id)!
        XCTAssertEqual(yoda.students.count, 2)

        let dumbledore = try teacherBox.get(teacher2.id)!
        XCTAssertEqual(dumbledore.students.count, 0)

        let claire = try studentBox.get(student3.id)!
        XCTAssertEqual(claire.teachers.count, 1)
        XCTAssertEqual(claire.teachers[0].id, teacher1.id)

        let alice = try studentBox.get(student1.id)!
        XCTAssertEqual(alice.teachers.count, 1)
        XCTAssertEqual(alice.teachers[0].id, teacher1.id)

        let bob = try studentBox.get(student2.id)!
        XCTAssertEqual(bob.teachers.count, 0)
    }

    func testManyToMany_appendAndApplyReverse() throws {
        try putTeachersAndStudents()

        student2.teachers.append(teacher2)
        try student2.teachers.applyToDb()

        student2.teachers.reset()
        student2.teachers.append(teacher1)
        try student2.teachers.applyToDb()

        student2.teachers.reset()
        XCTAssertEqual(student2.teachers.count, 2)

        let yoda = try teacherBox.get(teacher1.id)!
        XCTAssertEqual(yoda.students.count, 1)
        XCTAssertEqual(yoda.students[0].id, student2.id)

        let dumbledore = try teacherBox.get(teacher2.id)!
        XCTAssertEqual(dumbledore.students.count, 1)
        XCTAssertEqual(dumbledore.students[0].id, student2.id)

        let alice = try studentBox.get(student1.id)!
        XCTAssertEqual(alice.teachers.count, 0)

        let bob = try studentBox.get(student2.id)!
        XCTAssertEqual(bob.teachers.count, 2)

        let claire = try studentBox.get(student3.id)!
        XCTAssertEqual(claire.teachers.count, 0)
    }

    func testManyToMany_remove() throws {
        try putTeachersAndStudents()

        teacher1.students.append(student1)
        teacher1.students.append(student3)
        try teacher1.students.applyToDb()

        let removedId = teacher1.students.remove(at: 0).id
        XCTAssertEqual(removedId, student1.id)
        try teacher1.students.applyToDb()

        teacher1.students.reset()
        XCTAssertEqual(teacher1.students.count, 1)
        XCTAssertEqual(teacher1.students[0].id, student3.id)
    }

    func testManyToMany_removeReverse() throws {
        try putTeachersAndStudents()

        teacher1.students.append(student1)
        teacher1.students.append(student3)
        try teacher1.students.applyToDb()

        teacher2.students.append(student3)
        try teacher2.students.applyToDb()

        let claire = try studentBox.get(student3.id)!
        XCTAssertEqual(claire.teachers.count, 2)
        XCTAssertEqual(claire.teachers[0].id, teacher1.id)
        let removedId = claire.teachers.remove(at: 0).id
        XCTAssertEqual(removedId, teacher1.id)
        try claire.teachers.applyToDb()

        teacher1.students.reset()
        XCTAssertEqual(teacher1.students.count, 1)
        XCTAssertEqual(teacher1.students[0].id, student1.id)
    }

    func testManyToMany_replace() throws {
        try putTeachersAndStudents()

        teacher1.students.append(student1)
        teacher1.students.append(student2)
        teacher1.students.append(student3)
        try teacher1.students.applyToDb()

        let dan = Student(name: "Dan")
        try studentBox.put(dan)
        teacher1.students.replace([student2, dan])
        try teacher1.students.applyToDb()

        teacher1.students.replace([])
        teacher1.students.reset()
        XCTAssertEqual(teacher1.students.count, 2)
        XCTAssertEqual(teacher1.students[0].id, student2.id)
        XCTAssertEqual(teacher1.students[1].id, dan.id)
    }

    func testManyToMany_unsavedHost() throws {
        XCTAssertEqual(teacher1.students.count, 0)
        XCTAssertEqual(student1.teachers.count, 0)

        teacher1.students.append(student2)
        XCTAssertThrowsError(try teacher1.students.applyToDb())
        XCTAssertFalse(teacher1.students.canInteractWithDb)
        try teacherBox.put(teacher1)
        XCTAssert(teacher1.students.canInteractWithDb)
        try teacher1.students.applyToDb()
        XCTAssertNotEqual(teacher1.id, 0)
        XCTAssertNotEqual(student2.id, 0)
    }

}
