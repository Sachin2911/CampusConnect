package com.example.basics;

import android.os.Bundle;

import androidx.fragment.app.Fragment;
import androidx.fragment.app.FragmentTransaction;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.EditText;



public class CreateGroupFragment extends Fragment {

    EditText gc_name;
    String name;
    EditText gc_degree;
    String degree;
    EditText gc_num;
    String num;
    EditText gc_desc;
    String desc;
    Button button;

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        // Inflate the layout for this fragment
        View root = inflater.inflate(R.layout.fragment_create_group, container, false);

        gc_name = root.findViewById(R.id.et_Group_name);
        gc_degree = root.findViewById(R.id.et_Degree);
        gc_num = root.findViewById(R.id.editTextNumber);
        gc_desc = root.findViewById(R.id.et_description);
        button = root.findViewById(R.id.button);
        button.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                name = gc_name.getText().toString();
                degree = gc_degree.getText().toString();
                num = gc_num.getText().toString();
                desc = gc_desc.getText().toString();

                gc_name.setText("");
                gc_degree.setText("");
                gc_num.setText("");
                gc_desc.setText("");
                FragmentTransaction fragmentTransaction = getFragmentManager().beginTransaction();
                fragmentTransaction.replace(R.id.fragment_container, new MapActivity());
                fragmentTransaction.addToBackStack(null);
                fragmentTransaction.commit();

            }
        });
        return root;
    }
}