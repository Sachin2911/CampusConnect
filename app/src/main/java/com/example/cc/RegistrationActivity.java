package com.example.cc;

import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ProgressBar;
import android.widget.RadioButton;
import android.widget.RadioGroup;
import android.widget.TextView;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;

import com.google.android.gms.tasks.OnCompleteListener;
import com.google.android.gms.tasks.Task;
import com.google.firebase.auth.AuthResult;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseUser;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;

public class RegistrationActivity extends AppCompatActivity {

    private EditText emailEditText, passwordEditText, firstNameEditText,lastNameEditText,degreeEditText;
    private RadioGroup radGender;
    private DatabaseReference databaseReference;


    private TextView signInLink;
    private FirebaseAuth mAuth;

    private Button registerButton;

    private ProgressBar progressBar;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.register);

        // Initialize FirebaseAuth
        mAuth = FirebaseAuth.getInstance();

        // Initialize FirebaseDatabase
        databaseReference = FirebaseDatabase.getInstance().getReference("users");

        // Initialize UI elements
        firstNameEditText = findViewById(R.id.firstNameEditText);
        lastNameEditText = findViewById(R.id.lastNameEditText);
        degreeEditText = findViewById(R.id.degreeEditText);
        emailEditText = findViewById(R.id.emailEditText);
        passwordEditText = findViewById(R.id.passwordEditText);
        radGender = findViewById(R.id.radGender);
        registerButton = findViewById(R.id.registerButton);
        progressBar = findViewById(R.id.progressBar);
        signInLink = findViewById(R.id.signInLink);

        signInLink.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                // Add your code here to handle the click event
                // For example, you can open the sign-in activity here
                Intent intent = new Intent(getApplicationContext(), SignInActivity.class);
                startActivity(intent);
                // You may add finish() here if you want to close the current activity after starting the sign-in activity
            }
        });

        // Set click listener for the Register button
        registerButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                registerUser();
            }
        });
    }

    private void registerUser() {
        progressBar.setVisibility(View.VISIBLE);
        // Get the email and password entered by the user
        String firstName = firstNameEditText.getText().toString().trim();
        String lastName = lastNameEditText.getText().toString().trim();
        String degree = degreeEditText.getText().toString().trim();
//        String yearOfStudy = ((RadioButton) findViewById(radGender.getCheckedRadioButtonId())).getText().toString();
        String email = emailEditText.getText().toString().trim();
        String password = passwordEditText.getText().toString().trim();

        int selectedRadioButtonId = radGender.getCheckedRadioButtonId();
        if (selectedRadioButtonId == -1) {
            // No radio button is selected
            progressBar.setVisibility(View.GONE);
            Toast.makeText(this, "Please select Year of Study.", Toast.LENGTH_SHORT).show();
            return;
        }

        // Since a radio button is selected, find the selected radio button
        RadioButton selectedRadioButton = findViewById(selectedRadioButtonId);
        String yearOfStudy = selectedRadioButton.getText().toString();

        // Validate the input (you can add more validation as per your requirements)
        if (email.isEmpty() || password.isEmpty() || firstName.isEmpty() || lastName.isEmpty() || degree.isEmpty() || yearOfStudy.isEmpty() ) {
            progressBar.setVisibility(View.GONE);
            Toast.makeText(this, "Please fill in all fields. 🥹", Toast.LENGTH_SHORT).show();
            return;
        }

        // Create a user in FirebaseAuth
        mAuth.createUserWithEmailAndPassword(email, password)
                .addOnCompleteListener(this, new OnCompleteListener<AuthResult>() {
                    @Override
                    public void onComplete(@NonNull Task<AuthResult> task) {
                        progressBar.setVisibility(View.GONE);
                        if (task.isSuccessful()) {
                            FirebaseUser user = mAuth.getCurrentUser();
                            if (user != null) {
                                // Create a unique ID for the user
                                String userId = user.getUid();

                                // Create a User object
                                User userData = new User(userId, firstName, lastName, degree, yearOfStudy, email);

                                // Save the User object to Firebase Realtime Database
                                databaseReference.child(userId).setValue(userData);
                                Toast.makeText(RegistrationActivity.this, "You have registered successfully. 🥳", Toast.LENGTH_LONG).show();
                                Intent intent = new Intent(getApplicationContext(), SignInActivity.class);
                                startActivity(intent);
                                finish();
//                                        .addOnCompleteListener(new OnCompleteListener<Void>() {
//                                            @Override
//                                            public void onComplete(@NonNull Task<Void> setValueTask) {
//                                                if (setValueTask.isSuccessful()) {
//                                                    System.out.println("Hello there");
//                                                    Toast.makeText(RegistrationActivity.this, "You have registered successfully. 🥳", Toast.LENGTH_LONG).show();
//                                                    Intent intent = new Intent(getApplicationContext(), SignInActivity.class);
//                                                    startActivity(intent);
//                                                    finish();
//                                                } else {
//                                                    Toast.makeText(RegistrationActivity.this, "Registration failed. Please try again.😖", Toast.LENGTH_SHORT).show();
//                                                }
//                                            }
//                                        });
                            }
                        } else {
                            // If sign in fails, display a message to the user.
                            Toast.makeText(RegistrationActivity.this, "Something went wrong, check that details are correct.😵‍💫", Toast.LENGTH_SHORT).show();
                        }
                    }
                });
    }

}
