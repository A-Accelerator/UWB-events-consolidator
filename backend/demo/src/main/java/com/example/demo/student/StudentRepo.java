package com.example.demo.student;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface StudentRepo extends JpaRepository<Student, Integer> {
    //@Query("SELECT s FROM Student s WHERE s.id = ? 1")
    Optional<Student> findBySchoolID(String SchoolID);


}