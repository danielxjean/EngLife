package com.example.englifeapp;

import androidx.appcompat.app.AppCompatActivity;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.TextView;
import android.widget.Toast;

public class LogInActivity extends AppCompatActivity {

    TextView emailLogInEditText, passwordLogInEditText;
    DatabaseHelper db;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_log_in);
    }

    public void logInLogIn (View view){
        db = new DatabaseHelper(this);
        emailLogInEditText = findViewById(R.id.emailLogInEditText);
        passwordLogInEditText = findViewById(R.id.passwordLogInEditText);

        String email = emailLogInEditText.getText().toString();
        String password = passwordLogInEditText.getText().toString();

        Boolean Chkemailpassword = db.emailpassword(email, password);

        if(Chkemailpassword == true) {
            Toast.makeText(getApplicationContext(), "Logging In...", Toast.LENGTH_SHORT).show();
            startActivity(new Intent(logInActivity.this, MainActivity.class));
        }else{
            Toast.makeText(getApplicationContext(), "Wrong Email or Password", Toast.LENGTH_SHORT).show();
        }
    }

    public void signUpLogIn (View view){
        startActivity(new Intent(logInActivity.this, SignUpActivity.class));
    }

}
