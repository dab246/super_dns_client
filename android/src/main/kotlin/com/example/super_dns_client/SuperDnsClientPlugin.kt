package com.example.super_dns_client

import android.net.ConnectivityManager
import android.net.LinkProperties
import android.net.Network
import android.util.Log
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** SuperDnsClientPlugin */
class SuperDnsClientPlugin : FlutterPlugin, MethodCallHandler {

  private lateinit var channel: MethodChannel
  private var connectivityManager: ConnectivityManager? = null

  override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    if (BuildConfig.DEBUG) {
      Log.d("SuperDnsClientPlugin", "✅ Plugin attached to Flutter Engine")
    }

    // 🔗 NOTE: Channel name must match Dart side exactly
    channel = MethodChannel(binding.binaryMessenger, "super_dns_client")
    connectivityManager =
      binding.applicationContext.getSystemService(ConnectivityManager::class.java)

    channel.setMethodCallHandler(this)
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    if (BuildConfig.DEBUG) {
      Log.d("SuperDnsClientPlugin", "📞 Received method call: ${call.method}")
    }

    if (call.method == "getSystemDns") {
      try {
        val activeNetwork: Network? = connectivityManager?.activeNetwork
        val linkProperties: LinkProperties? =
          connectivityManager?.getLinkProperties(activeNetwork)

        val servers = linkProperties?.dnsServers?.map { it.hostAddress } ?: emptyList()
        if (BuildConfig.DEBUG) {
          Log.d("SuperDnsClientPlugin", "📡 Found DNS servers: $servers")
        }

        result.success(servers)
      } catch (e: Exception) {
        if (BuildConfig.DEBUG) {
          Log.e("SuperDnsClientPlugin", "❌ Error retrieving DNS: ${e.message}", e)
        }
        result.error("ERROR", e.message, null)
      }
    } else {
      result.notImplemented()
    }
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    if (BuildConfig.DEBUG) {
      Log.d("SuperDnsClientPlugin", "🧹 Plugin detached from Flutter Engine")
    }
    channel.setMethodCallHandler(null)
    connectivityManager = null
  }
}
