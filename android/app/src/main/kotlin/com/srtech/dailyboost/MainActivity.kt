package com.srtech.dailyboost

import android.app.AlertDialog
import android.os.Bundle
import android.util.Log
import com.google.android.gms.common.ConnectionResult
import com.google.android.gms.common.GoogleApiAvailability
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val TAG = "MainActivity"
    private val ERROR_DIALOG_REQUEST = 9001
    private val CHANNEL = "com.srtech.dailyboost/playservices"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // Set up method channel for Play Services checks
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "isGooglePlayServicesAvailable" -> {
                    result.success(isGooglePlayServicesAvailable())
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // Check if Google Play Services is available
        if (!isServicesOK()) {
            Log.e(TAG, "Google Play Services not available or outdated")
        }
    }
    
    // Check if Google Play Services is available without showing dialog
    private fun isGooglePlayServicesAvailable(): Boolean {
        val available = GoogleApiAvailability.getInstance().isGooglePlayServicesAvailable(this)
        return available == ConnectionResult.SUCCESS
    }
    
    // Check if Google Play Services is available and up to date
    private fun isServicesOK(): Boolean {
        Log.d(TAG, "isServicesOK: checking Google Play services version")
        val available = GoogleApiAvailability.getInstance().isGooglePlayServicesAvailable(this)
        
        if (available == ConnectionResult.SUCCESS) {
            // Everything is fine and the user can make map requests
            Log.d(TAG, "isServicesOK: Google Play Services is working")
            return true
        } else if (GoogleApiAvailability.getInstance().isUserResolvableError(available)) {
            // An error occurred but we can resolve it
            Log.d(TAG, "isServicesOK: an error occurred but we can fix it")
            val dialog = GoogleApiAvailability.getInstance()
                .getErrorDialog(this, available, ERROR_DIALOG_REQUEST)
            dialog?.show()
        } else {
            // Error can't be resolved
            AlertDialog.Builder(this)
                .setTitle("Google Play Services")
                .setMessage("Google Play Services is required for this app. Please install Google Play Services to continue.")
                .setPositiveButton("OK") { dialog, _ -> dialog.dismiss() }
                .create()
                .show()
            Log.e(TAG, "isServicesOK: Google Play services is not available on this device")
        }
        
        return false
    }
}
