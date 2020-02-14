package com.example.englifeapp;

import androidx.appcompat.app.AppCompatActivity;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.ArrayAdapter;
import android.widget.EditText;
import android.widget.Spinner;
import android.widget.Toast;

public class SignUpActivity extends AppCompatActivity {

    EditText userNameSignUpEditText, emailSignUpEditText, passwordSignUpEditText, confirmPasswordSignUpEditText;
    Spinner majorSignUpSpinner;
    DatabaseHelper db;
    //get the spinner from the xml.


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_sign_up);
      
        majorSignUpSpinner = findViewById(R.id.majorSignupSpinner);
        String[] majors = new String[]{"Software Engineering", "Computer Engineering", "Aerospace Engineering", "Building Engineering", "Civil Engineering", "Electrical Engineering", "Industrial Engineering", "Mechanical Engineering"};
        ArrayAdapter<String> adapter = new ArrayAdapter<>(this, android.R.layout.simple_spinner_dropdown_item, majors);
        majorSignUpSpinner.setAdapter(adapter);
    }

    public void register (View view){
        userNameSignUpEditText = findViewById(R.id.userNameSignUpEditText);
        emailSignUpEditText = findViewById(R.id.emailSignUpEditText);
        passwordSignUpEditText = findViewById(R.id.passwordSignUpEditText);
        confirmPasswordSignUpEditText = findViewById(R.id.confirmPasswordSignUpEditText);
        majorSignUpSpinner = findViewById(R.id.majorSignupSpinner);
        db = new DatabaseHelper(this);

        String username = userNameSignUpEditText.getText().toString();
        String email = emailSignUpEditText.getText().toString();
        String password = passwordSignUpEditText.getText().toString();
        String confirm = confirmPasswordSignUpEditText.getText().toString();
        String major = majorSignUpSpinner.getSelectedItem().toString();

        if(username.equals("") || email.equals("") || password.equals("") || confirm.equals("") || major.equals("")){
            Toast.makeText(getApplicationContext(), "Fill in the required fields", Toast.LENGTH_SHORT).show();
        }
        else if(!password.equals(confirm)){
            Toast.makeText(getApplicationContext(), "Password is not the same", Toast.LENGTH_SHORT).show();
        }
        else{
            Boolean checkmail =db.chkmail(email);
            if(checkmail == true){
                Boolean insert = db.insert(email, username, password, major);
                if(insert){
                    Toast.makeText(getApplicationContext(), "Registering...", Toast.LENGTH_SHORT).show();
                    startActivity(new Intent(SignUpActivity.this, GroupsActivity.class));
                }
            }
            else{
                Toast.makeText(getApplicationContext(),"Email already exists", Toast.LENGTH_SHORT).show();
            }
        }
    }
}
