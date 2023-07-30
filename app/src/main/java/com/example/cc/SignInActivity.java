package com.example.cc;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;

import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ProgressBar;
import android.widget.TextView;
import android.widget.Toast;

import com.google.android.gms.tasks.OnCompleteListener;
import com.google.android.gms.tasks.Task;
import com.google.firebase.FirebaseApp;
import com.google.firebase.auth.AuthResult;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseUser;

public class SignInActivity extends AppCompatActivity {

    private EditText emailEditText, passwordEditText;

    private TextView register;
    private FirebaseAuth mAuth;

    private Button loginButton;

    private ProgressBar progressBar;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.login);
        // Initialize FirebaseAuth
        mAuth = FirebaseAuth.getInstance();

        // Initialize UI elements
        emailEditText = findViewById(R.id.emailEditText);
        passwordEditText = findViewById(R.id.passwordEditText);
        loginButton = findViewById(R.id.loginButton);
        progressBar = findViewById(R.id.progressBar);
        register = findViewById(R.id.createAccount);

        // If not registered redirect to registration activity
        register.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Intent intent = new Intent(getApplicationContext(), RegistrationActivity.class);
                startActivity(intent);
                finish();
            }
        });

        // Set click listener for the Login button
        loginButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                loginUser();
            }
        });
    }

    private void loginUser() {
        progressBar.setVisibility(View.VISIBLE);
        // Get the email and password entered by the user
        String email = emailEditText.getText().toString().trim();
        String password = passwordEditText.getText().toString().trim();

        // Validate the input (you can add more validation as per your requirements)
        if (email.isEmpty() || password.isEmpty()) {
            progressBar.setVisibility(View.GONE);
            Toast.makeText(this, "Please fill in all fields. 🥹", Toast.LENGTH_SHORT).show();
            return;
        }

        mAuth.signInWithEmailAndPassword(email, password)
                .addOnCompleteListener(this, new OnCompleteListener<AuthResult>() {
                    @Override
                    public void onComplete(@NonNull Task<AuthResult> task) {
                        progressBar.setVisibility(View.GONE);
                        if (task.isSuccessful()) {
                            Toast.makeText(SignInActivity.this, "You have logged in successfully. 🥳", Toast.LENGTH_LONG).show();
                            Intent intent = new Intent(getApplicationContext(), MainActivity.class);
                            startActivity(intent);
                            finish();
                        } else {
                            // If sign in fails, display a message to the user.
                            Toast.makeText(SignInActivity.this, "Authentication failed.😱",
                                    Toast.LENGTH_SHORT).show();
                        }
                    }
                });

    }
}
