package com.example.englifeapp;

import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;

import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.provider.MediaStore;
import android.view.View;
import android.widget.Button;

public class ProfileActivity extends AppCompatActivity {

    private final int MAX_PHOTO_PER_ROW = 3;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_profile);

        setupAddPhotoBtn();
    }

    public void setupAddPhotoBtn(){
        Button addPhotoBtn = (Button)findViewById(R.id.addPhoto);
        addPhotoBtn.setOnClickListener(new View.OnClickListener(){

            @Override
            public void onClick(View v) {
                addPhoto();
            }
        });
    }

    public void addPhoto(){
        Intent intent = new Intent(Intent.ACTION_PICK, MediaStore.Images.Media.EXTERNAL_CONTENT_URI);
        startActivityForResult(intent, 1);
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, @Nullable Intent data) {
        super.onActivityResult(requestCode, resultCode, data);

        if (requestCode == 1 && resultCode == RESULT_OK && data != null){

            Uri selectedImage = data.getData();

            
        }

    }
}
