package com.unibo.tab_writer.layout;

import android.os.Bundle;

import androidx.preference.EditTextPreference;
import androidx.preference.PreferenceFragmentCompat;

import com.unibo.tab_writer.R;

public class SettingsFragment extends PreferenceFragmentCompat {

    @Override
    public void onCreatePreferences(Bundle savedInstanceState, String rootKey) {
        setPreferencesFromResource(R.xml.root_preferences, rootKey);

        EditTextPreference ipPreference = findPreference("ip");
        EditTextPreference portPreference = findPreference("port");

        ipPreference.getText();
        portPreference.getText();
    }
}