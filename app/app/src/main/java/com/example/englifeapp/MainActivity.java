package com.example.englifeapp;

import androidx.appcompat.app.AppCompatActivity;

import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;

public class MainActivity extends AppCompatActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        configureSwitchToGroupsButton();
    }

    private void configureSwitchToGroupsButton(){
        Button finishBtn = (Button)findViewById(R.id.finish_groups_button);

        finishBtn.setOnClickListener(new View.OnClickListener() {

            @Override
            public void onClick(View v) {
                startActivity(new Intent(MainActivity.this, GroupsActivity.class));
            }
        });
    }
}
