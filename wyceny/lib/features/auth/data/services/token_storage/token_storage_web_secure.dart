// lib/core/auth/token_storage_web_secure.dart

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'dart:js_interop';             // toJS / toDart + JS* typy
import 'dart:js_util' as jsu;         // jsify, promiseToFuture
import 'package:web/web.dart' as web; // Web APIs

import 'package:wyceny/features/auth/data/services/token_storage.dart';

TokenStorage createPlatformTokenStorage() => SecureWebTokenStorage();

const _kLsPrefix   = 'secure_token_';
const _kDbName     = 'secure_token_db';
const _kStoreName  = 'crypto_keys';
const _kKeyId      = 'aes_gcm_key_v1';

class SecureWebTokenStorage implements TokenStorage {
  SecureWebTokenStorage() {
    _init = _openDbAndLoadOrCreateKey();
  }

  late final Future<void> _init;
  web.IDBDatabase? _db;
  web.CryptoKey? _aesKey;

  // ================= TokenStorage API =================

  @override
  Future<void> write(String key, String value) async {
    await _init;
    final k   = _requireKey();
    final aad = Uint8List.fromList(utf8.encode(key));
    final pt  = Uint8List.fromList(utf8.encode(value));

    final iv = Uint8List(12);
    web.window.crypto.getRandomValues(iv.toJS); // wypełnia iv na miejscu

    final alg = jsu.jsify({
      'name': 'AES-GCM',
      'iv': iv.toJS,                // BufferSource
      'additionalData': aad.toJS,   // BufferSource
      'tagLength': 128,
    });

    final subtle = web.window.crypto.subtle;
    final jsBuf = await jsu.promiseToFuture<JSArrayBuffer>(
      subtle.encrypt(alg, k, pt.toJS),
    );

    final ct = Uint8List.view(jsBuf.toDart); // -> ByteBuffer -> Uint8List

    final blob = _CipherPayload(v: 1, aadKey: key, iv: iv, ciphertext: ct).toBase64();
    web.window.localStorage.setItem('$_kLsPrefix$key', blob);
  }

  @override
  Future<String?> read(String key) async {
    await _init;
    final payloadB64 = web.window.localStorage.getItem('$_kLsPrefix$key');
    if (payloadB64 == null) return null;

    final p = _CipherPayload.fromBase64(payloadB64);
    if (p.v != 1 || p.aadKey != key) return null;

    final k   = _requireKey();
    final aad = Uint8List.fromList(utf8.encode(key));

    final alg = jsu.jsify({
      'name': 'AES-GCM',
      'iv': p.iv.toJS,
      'additionalData': aad.toJS,
      'tagLength': 128,
    });

    final subtle = web.window.crypto.subtle;
    try {
      final jsBuf = await jsu.promiseToFuture<JSArrayBuffer>(
        subtle.decrypt(alg, k, p.ciphertext.toJS),
      );
      final pt = Uint8List.view(jsBuf.toDart);
      return utf8.decode(pt);
    } catch (_) {
      // zła integralność / podmieniony ładunek itp.
      return null;
    }
  }

  @override
  Future<void> delete(String key) async {
    await _init;
    web.window.localStorage.removeItem('$_kLsPrefix$key');
  }

  // ================= Klucz / IndexedDB =================

  Future<void> _openDbAndLoadOrCreateKey() async {
    _db = await _openDb();

    _aesKey = await _getKeyFromIdb();
    if (_aesKey == null) {
      // SubtleCrypto.generateKey(AlgorithmIdentifier, extractable, keyUsages[])
      final key = await jsu.promiseToFuture<web.CryptoKey>(
        web.window.crypto.subtle.generateKey(
          jsu.jsify({'name': 'AES-GCM', 'length': 256}),
          false,
          jsu.jsify(['encrypt', 'decrypt']),
        ),
      );
      await _putKeyToIdb(key);
      _aesKey = key;
    }
  }

  web.CryptoKey _requireKey() {
    final k = _aesKey;
    if (k == null) throw StateError('AES-GCM key not initialized');
    return k;
  }

  Future<web.IDBDatabase> _openDb() async {
    final req = web.window.indexedDB.open(_kDbName, 1);
    final c = Completer<web.IDBDatabase>();

    jsu.setProperty(req, 'onupgradeneeded', jsu.allowInterop((web.Event _) {
      final db = req.result as web.IDBDatabase;
      if (!db.objectStoreNames.contains(_kStoreName)) {
        db.createObjectStore(_kStoreName);
      }
    }));

    jsu.setProperty(req, 'onsuccess', jsu.allowInterop((web.Event _) {
      c.complete(req.result as web.IDBDatabase);
    }));

    jsu.setProperty(req, 'onerror', jsu.allowInterop((web.Event _) {
      c.completeError(req.error ?? 'IndexedDB open error');
    }));

    return c.future;
  }

  Future<void> _putKeyToIdb(web.CryptoKey key) async {
    final tx = _db!.transaction(_kStoreName.toJS, 'readwrite');
    final store = tx.objectStore(_kStoreName);
    await _awaitReq(store.put(key, _kKeyId.toJS));
    await _awaitTx(tx);
  }

  Future<web.CryptoKey?> _getKeyFromIdb() async {
    final tx = _db!.transaction(_kStoreName.toJS, 'readonly');
    final store = tx.objectStore(_kStoreName);
    final res = await _awaitReq(store.get(_kKeyId.toJS));
    await _awaitTx(tx);
    return (res is web.CryptoKey) ? res : null;
  }

  Future<dynamic> _awaitReq(web.IDBRequest req) {
    final c = Completer<dynamic>();

    jsu.setProperty(req, 'onsuccess', jsu.allowInterop((web.Event _) {
      c.complete(req.result);
    }));

    jsu.setProperty(req, 'onerror', jsu.allowInterop((web.Event _) {
      c.completeError(req.error ?? 'IDB request error');
    }));

    return c.future;
  }

  Future<void> _awaitTx(web.IDBTransaction tx) {
    final c = Completer<void>();

    jsu.setProperty(tx, 'oncomplete', jsu.allowInterop((web.Event _) {
      c.complete();
    }));

    jsu.setProperty(tx, 'onerror', jsu.allowInterop((web.Event _) {
      c.completeError('IDB tx error');
    }));

    jsu.setProperty(tx, 'onabort', jsu.allowInterop((web.Event _) {
      c.completeError('IDB tx aborted');
    }));

    return c.future;
  }
}

// === serializacja ładunku ===

class _CipherPayload {
  final int v;
  final String aadKey;
  final Uint8List iv;
  final Uint8List ciphertext;

  _CipherPayload({required this.v, required this.aadKey, required this.iv, required this.ciphertext});

  String toBase64() => base64Encode(utf8.encode(json.encode({
    'v': v,
    'k': aadKey,
    'iv': base64Encode(iv),
    'ct': base64Encode(ciphertext),
  })));

  static _CipherPayload fromBase64(String b64) {
    final map = json.decode(utf8.decode(base64Decode(b64))) as Map<String, dynamic>;
    return _CipherPayload(
      v: map['v'] as int,
      aadKey: map['k'] as String,
      iv: Uint8List.fromList(base64Decode(map['iv'] as String)),
      ciphertext: Uint8List.fromList(base64Decode(map['ct'] as String)),
    );
  }
}
