package com.example.englifeapp;

import androidx.appcompat.app.AppCompatActivity;

import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;

public class GroupsActivity extends AppCompatActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_groups);

        configureInfoTextView();
        configureSwitchToGroupsButton();
    }

    private void configureSwitchToGroupsButton(){
        Button finishBtn = (Button)findViewById(R.id.finish_group_button);

        finishBtn.setOnClickListener(new View.OnClickListener() {

            @Override
            public void onClick(View v) {
                Intent intent = new Intent(GroupsActivity.this, ProfileActivity.class);
                startActivity(intent);
            }
        });
    }

    private void configureInfoTextView(){
        TextView infoText = (TextView)findViewById(R.id.info_groups_textview);
        String info = "On this page you can select from various Concordia societies.\n" +
                      "Selecting a society will let you see their posts and updates \n" +
                      "on your newsfeed. Societies post about events and information on how to become members!";
        infoText.setText(info);
    }

}
