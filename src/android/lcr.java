package org.iii.plugin.lcr;

import android.Manifest;
import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.os.Build;
import android.os.Bundle;
import android.util.Log;
import android.view.View;

import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CallbackContext;
import org.apache.cordova.PluginResult;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;



/**
 * This class echoes a string called from JavaScript.
 */
public class lcr extends CordovaPlugin {

    private static final int SCAN_REQUEST = 1;

    public static final String CAMERA = Manifest.permission.CAMERA;
    public static final int CAMERA_REQ_CODE = 2;

    public static final int PERMISSION_DENIED_ERROR = 20;

    private CallbackContext mScanCallbackContext = null;

    //
    private String m_strClose;
    private String m_strScaning;
    private String m_strCamera;
    private String m_strScanFontSize;
    private String m_strEnableFlash;
    private String m_strCustomImage;
    private String m_strShowSwitchBtn;

    @Override
    public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
        if (action.equals("scan")) {
            //
            m_strClose = args.getString(0);
            m_strScaning = args.getString(1);
            m_strCamera = args.getString(2);
            m_strScanFontSize = args.getString(3);
            m_strEnableFlash = args.getString(4);
            m_strCustomImage = args.getString(5);
            m_strShowSwitchBtn = args.getString(6);
            Log.d("lcr", "plugin arg0 = " + m_strClose);
            Log.d("lcr", "plugin arg1 = " + m_strScaning);
            Log.d("lcr", "plugin arg2 = " + m_strCamera);
            Log.d("lcr", "plugin arg3 = " + m_strScanFontSize);
            Log.d("lcr", "plugin arg4 = " + m_strEnableFlash);
            Log.d("lcr", "plugin arg5 = " + m_strCustomImage);
            Log.d("lcr", "plugin arg6 = " + m_strShowSwitchBtn);
            //
            this.scan(callbackContext);
            return true;
        }
        return false;
    }

    @Override
    public void onActivityResult(final int requestCode, final int resultCode, final Intent data) {
        Log.d("lcr", "onActivityResult, " + requestCode + "," + resultCode);
        if(requestCode == SCAN_REQUEST) {
            if(resultCode == cordova.getActivity().RESULT_OK) {
                Bundle extras = data.getExtras();
                String information = extras.getString("data");
                Log.d("lcr", "onActivityResult, data=" + information); 
                PluginResult result = new PluginResult(PluginResult.Status.OK, information);
                result.setKeepCallback(true);
                mScanCallbackContext.sendPluginResult(result);
                return;
            } else if (resultCode == cordova.getActivity().RESULT_FIRST_USER) {
                //
                //PluginResult result = new PluginResult(PluginResult.Status.ERROR, "LCR doesn't support this camera.");
                //result.setKeepCallback(true);
                //mScanCallbackContext.sendPluginResult(result);
                mScanCallbackContext.error("LCR doesn't support this camera.");
            } else {
                PluginResult result = new PluginResult(PluginResult.Status.OK, "");
                result.setKeepCallback(true);
                mScanCallbackContext.sendPluginResult(result);
                return;
            }
        } 
        super.onActivityResult(requestCode, resultCode, data);
    }

    public void onRequestPermissionResult(int requestCode, String[] permissions, int[] grantResults) throws JSONException
    {
        for(int r:grantResults)
        {
            if(r == PackageManager.PERMISSION_DENIED)
            {
                mScanCallbackContext.sendPluginResult(new PluginResult(PluginResult.Status.ERROR, PERMISSION_DENIED_ERROR));
                return;
            }
        }
        switch(requestCode)
        {
            case CAMERA_REQ_CODE:
                _scan();
                break;
        }
    }

    private void scan(CallbackContext callbackContext) {
        mScanCallbackContext = callbackContext;
        //檢查是否具有相機開啟權限
        if(cordova.hasPermission(CAMERA))
        {
            _scan();
        }
        else
        {
            cordova.requestPermission(this, CAMERA_REQ_CODE, CAMERA);
        }
    }

    private void _scan() {
        Context context = cordova.getActivity().getApplicationContext();
        /****************************
         檢查此手機需使用何種API
         Only support >= SDK 21
         ************************/

        Log.d("camera2","use camera2 API");
        Intent intent = new Intent(context, ScanCamera2Activity.class);
        //
        Bundle args = new Bundle();
        args.putString("key_close", m_strClose);
        args.putString("key_scan", m_strScaning);
        args.putString("key_camera", m_strCamera);
        args.putString("key_scan_fontsize", m_strScanFontSize);
        args.putString("key_enable_flash", m_strEnableFlash);
        args.putString("key_custom_image", m_strCustomImage);
        args.putString("key_show_switchbtn", m_strShowSwitchBtn);
        intent.putExtras(args);
        cordova.startActivityForResult((CordovaPlugin) this, intent, SCAN_REQUEST);

        PluginResult pluginResult = new PluginResult(PluginResult.Status.NO_RESULT);
        pluginResult.setKeepCallback(true);
    }
}
