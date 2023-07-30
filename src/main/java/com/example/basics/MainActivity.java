package com.example.basics;

import androidx.annotation.NonNull;
import androidx.appcompat.app.ActionBarDrawerToggle;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.view.GravityCompat;
import androidx.drawerlayout.widget.DrawerLayout;
import androidx.fragment.app.Fragment;

import android.os.Bundle;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.MenuItem;
import android.view.View;
import android.widget.EditText;
import android.widget.RelativeLayout;
import android.widget.TextView;

import androidx.appcompat.widget.Toolbar;
import androidx.fragment.app.FragmentManager;
//import android.widget.Toolbar;

import com.google.android.material.navigation.NavigationView;


public class MainActivity extends AppCompatActivity  implements NavigationView.OnNavigationItemSelectedListener{

    private DrawerLayout drawerLayout;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        Toolbar toolbar = (Toolbar) findViewById(R.id.toolbar);
        setSupportActionBar(toolbar);
        drawerLayout = findViewById(R.id.drawer);
        NavigationView navigationView = findViewById(R.id.nav);
        navigationView.setNavigationItemSelectedListener(this);
        ActionBarDrawerToggle toggle = new ActionBarDrawerToggle(this, drawerLayout,toolbar,R.string.nav_open,R.string.nav_close);
        drawerLayout.addDrawerListener(toggle);
        toggle.syncState();

        if(savedInstanceState == null) {
            getSupportFragmentManager().beginTransaction().replace(R.id.fragment_container, new AnotherFragment()).commit();
            navigationView.setCheckedItem(R.id.another);
        }
    }

    @Override
    public boolean onNavigationItemSelected(@NonNull MenuItem item) {
        switch(item.getItemId()){
            case R.id.another:
                getSupportFragmentManager().beginTransaction().replace(R.id.fragment_container, new AnotherFragment()).commit();
                break;
            case R.id.session:
                getSupportFragmentManager().beginTransaction().replace(R.id.fragment_container, new SessionFragment()).commit();
                break;
            case R.id.group:
                getSupportFragmentManager().beginTransaction().replace(R.id.fragment_container, new StudyGroup()).commit();
                break;
            case R.id.logout:
                getSupportFragmentManager().beginTransaction().replace(R.id.fragment_container, new Logout()).commit();
                try {
                    Thread.sleep(2000);
                    Fragment fragment = getSupportFragmentManager().findFragmentById(R.id.fragment_container);
                    Bundle bundle = new Bundle();
                    bundle.putString("msg","Hello");
                    getSupportFragmentManager().beginTransaction().replace(R.id.fragment_container, new StudyGroup()).commit();
                    break;
                } catch (InterruptedException e) {
                    throw new RuntimeException(e);
                }

                //Bundle result = new Bundle();
                //result.putString("msg","Exited");
                //getSupportFragmentManager().beginTransaction();
                //getSupportFragmentManager().setFragmentResult("logout", result);
            case R.id.Create:
                getSupportFragmentManager().beginTransaction().replace(R.id.fragment_container, new CreateGroupFragment()).commit();
                break;
        }
        drawerLayout.closeDrawer(GravityCompat.START);
        return true;
    }


    @Override
    public void onBackPressed() {
        if(drawerLayout.isDrawerOpen(GravityCompat.START)){
            drawerLayout.closeDrawer(GravityCompat.START);
        }else {
            super.onBackPressed();
        }
    }
}