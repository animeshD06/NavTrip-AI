(function () {
  let currentAbortController;

  function base64UrlToBytes(value) {
    if (typeof value !== 'string') {
      return new Uint8Array();
    }

    const padded = value.replace(/-/g, '+').replace(/_/g, '/') + '==='.slice((value.length + 3) % 4);
    const binary = atob(padded);
    const bytes = new Uint8Array(binary.length);
    for (let i = 0; i < binary.length; i += 1) {
      bytes[i] = binary.charCodeAt(i);
    }
    return bytes;
  }

  function bytesToBase64Url(value) {
    const bytes = value instanceof ArrayBuffer ? new Uint8Array(value) : value;
    let binary = '';
    for (let i = 0; i < bytes.length; i += 1) {
      binary += String.fromCharCode(bytes[i]);
    }
    return btoa(binary).replace(/\+/g, '-').replace(/\//g, '_').replace(/=+$/g, '');
  }

  function decodeCredentialId(value) {
    return base64UrlToBytes(value).buffer;
  }

  function toUint8Array(value) {
    return base64UrlToBytes(value);
  }

  function toPublicKeyCreationOptions(payload) {
    const publicKey = payload.publicKey;

    return {
      challenge: toUint8Array(publicKey.challenge),
      rp: publicKey.rp,
      user: {
        ...publicKey.user,
        id: toUint8Array(publicKey.user.id),
      },
      pubKeyCredParams: publicKey.pubKeyCredParams,
      timeout: publicKey.timeout,
      attestation: publicKey.attestation,
      authenticatorSelection: publicKey.authenticatorSelection || undefined,
      excludeCredentials: (publicKey.excludeCredentials || []).map((credential) => ({
        ...credential,
        id: decodeCredentialId(credential.id),
      })),
    };
  }

  function toPublicKeyRequestOptions(payload) {
    const publicKey = payload.publicKey;
    return {
      challenge: toUint8Array(publicKey.challenge),
      timeout: publicKey.timeout,
      rpId: publicKey.rpId || undefined,
      userVerification: publicKey.userVerification || undefined,
      allowCredentials: (publicKey.allowCredentials || []).map((credential) => ({
        ...credential,
        id: decodeCredentialId(credential.id),
      })),
    };
  }

  function fromRegistrationCredential(credential) {
    const response = credential.response;
    return {
      id: credential.id,
      rawId: bytesToBase64Url(credential.rawId),
      response: {
        clientDataJSON: bytesToBase64Url(response.clientDataJSON),
        attestationObject: bytesToBase64Url(response.attestationObject),
        transports: typeof response.getTransports === 'function' ? response.getTransports() || [] : [],
      },
    };
  }

  function fromAssertionCredential(credential) {
    const response = credential.response;
    return {
      id: credential.id,
      rawId: bytesToBase64Url(credential.rawId),
      response: {
        clientDataJSON: bytesToBase64Url(response.clientDataJSON),
        authenticatorData: bytesToBase64Url(response.authenticatorData),
        signature: bytesToBase64Url(response.signature),
        userHandle: response.userHandle ? bytesToBase64Url(response.userHandle) : null,
      },
    };
  }

  function platformError(error) {
    if (error instanceof DOMException) {
      if (error.name === 'NotAllowedError') {
        return {
          code: 'cancelled',
          message: 'operation was cancelled by the user.',
          details: '',
        };
      }

      return {
        code: error.name,
        message: error.message,
        details: '',
      };
    }

    if (typeof error === 'string') {
      return {
        code: 'unknown',
        message: error,
        details: '',
      };
    }

    return {
      code: 'unknown',
      message: error?.message || 'unknown passkey error',
      details: '',
    };
  }

  class PasskeyAuthenticator {
    async register(params) {
      try {
        const typedParams = JSON.parse(params);
        const credential = await navigator.credentials.create({
          publicKey: toPublicKeyCreationOptions(typedParams),
        });

        if (!credential) {
          throw new DOMException('Operation was cancelled.', 'NotAllowedError');
        }

        return JSON.stringify(fromRegistrationCredential(credential));
      } catch (error) {
        return Promise.reject(JSON.stringify(platformError(error)));
      }
    }

    async login(params) {
      try {
        currentAbortController = new AbortController();
        const typedParams = JSON.parse(params);
        const credential = await navigator.credentials.get({
          publicKey: toPublicKeyRequestOptions(typedParams),
          mediation: typedParams.mediation,
          signal: currentAbortController.signal,
        });

        if (!credential) {
          throw new DOMException('Operation was cancelled.', 'NotAllowedError');
        }

        return JSON.stringify(fromAssertionCredential(credential));
      } catch (error) {
        return Promise.reject(JSON.stringify(platformError(error)));
      }
    }

    abortCurrentWebAuthnOperation() {
      if (currentAbortController) {
        currentAbortController.abort('operation aborted by user.');
      }
    }
  }

  window.PasskeyAuthenticator = PasskeyAuthenticator;
  window.PasskeyAuthenticator.init = function () {};
  window.PasskeyAuthenticator.hasPasskeySupport = function () {
    return Boolean(window.PublicKeyCredential);
  };
  window.PasskeyAuthenticator.isUserVerifyingPlatformAuthenticatorAvailable = async function () {
    if (!window.PublicKeyCredential) {
      return undefined;
    }

    try {
      return await window.PublicKeyCredential.isUserVerifyingPlatformAuthenticatorAvailable();
    } catch (_) {
      return undefined;
    }
  };
  window.PasskeyAuthenticator.isConditionalMediationAvailable = async function () {
    if (!window.PublicKeyCredential) {
      return undefined;
    }

    try {
      return await window.PublicKeyCredential.isConditionalMediationAvailable();
    } catch (_) {
      return undefined;
    }
  };
})();
