package com.example.cc;

public class User {
    private String userId;
    private String firstName;
    private String lastName;
    private String degree;
    private String yearOfStudy;
    private String email;

    public User() {
        // Empty constructor required for Firebase
    }

    public User(String userId, String firstName, String lastName, String degree, String yearOfStudy, String email) {
        this.userId = userId;
        this.firstName = firstName;
        this.lastName = lastName;
        this.degree = degree;
        this.yearOfStudy = yearOfStudy;
        this.email = email;
    }

    public String getUserId() {
        return userId;
    }

    public void setUserId(String userId) {
        this.userId = userId;
    }

    public String getFirstName() {
        return firstName;
    }

    public void setFirstName(String firstName) {
        this.firstName = firstName;
    }

    public String getDegree() {
        return degree;
    }

    public void setDegree(String degree) {
        this.degree = degree;
    }

    public String getYearOfStudy() {
        return yearOfStudy;
    }

    public void setYearOfStudy(String yearOfStudy) {
        this.yearOfStudy = yearOfStudy;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getLastName() {
        return lastName;
    }

    public void setLastName(String lastName) {
        this.lastName = lastName;
    }

}
