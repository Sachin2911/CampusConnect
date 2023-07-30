package com.example.basics;

import android.os.Bundle;

import androidx.fragment.app.Fragment;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.ListView;
import android.widget.SearchView;
import android.widget.Toast;

public class GroupFragment extends Fragment {

    ListView listView;
    SearchView searchView;
    ArrayAdapter<String> adapter;
    String [] data = {"Saahin","Daniel","Tshepiso"};

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        // Inflate the layout for this fragment
        View view = inflater.inflate(R.layout.fragment_group, container, false);
        listView = (ListView) view.findViewById(R.id.List_groups);
        adapter = new ArrayAdapter<String>(getActivity(), android.R.layout.simple_list_item_1,data);
        listView.setAdapter(adapter);
        return view;
    }
}