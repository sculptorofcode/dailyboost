package com.srtech.dailyboost

import android.content.Context
import android.util.Log
import androidx.multidex.MultiDexApplication
import com.google.android.gms.common.GoogleApiAvailability
import com.google.android.gms.common.ConnectionResult
import com.google.firebase.FirebaseApp

class DailyBoostApplication : MultiDexApplication() {
    companion object {
        private const val TAG = "DailyBoostApplication"
    }

    override fun attachBaseContext(base: Context) {
        super.attachBaseContext(base)
        // Initialize MultiDex
        androidx.multidex.MultiDex.install(this)
    }

    override fun onCreate() {
        super.onCreate()
        try {
            Log.d(TAG, "Application onCreate called")
            // Check Google Play Services availability
            val resultCode = GoogleApiAvailability.getInstance().isGooglePlayServicesAvailable(this)
            if (resultCode != ConnectionResult.SUCCESS) {
                Log.w(TAG, "Google Play Services is not available ($resultCode)")
                // Don't initialize Firebase if Play Services is not available
            } else {
                Log.i(TAG, "Google Play Services is available and up-to-date")
                // Initialize Firebase only if Play Services is available
                FirebaseApp.initializeApp(this)
                Log.i(TAG, "Firebase initialized successfully")
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error initializing app dependencies", e)
        }
    }
}
