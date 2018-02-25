/* A JavaScript implementation of the Secure Hash Algorithm, SHA-256
 * Version 0.3 Copyright Angel Marin 2003-2004 - http://anmar.eu.org/
 * Distributed under the BSD License
 * Some bits taken from Paul Johnston's SHA-1 implementation
 */
'use strict';
// @ts-check

// var chrsz = 8;
// module.exports = {

//     chrsz: function() {return 8},

//     /* bits per input character. 8 - ASCII; 16 - Unicode  */
//     this.safe_add: function(x, y) {
//         var lsw = (x & 0xFFFF) + (y & 0xFFFF);
//         var msw = (x >> 16) + (y >> 16) + (lsw >> 16);
//         return (msw << 16) | (lsw & 0xFFFF);
//     },
//     this.S: function (X, n) { return (X >>> n) | (X << (32 - n)); },
//     this.R: function (X, n) { return (X >>> n); },
//     this.Ch: function (x, y, z) { return ((x & y) ^ ((~x) & z)); },
//     this.Maj: function (x, y, z) { return ((x & y) ^ (x & z) ^ (y & z)); },
//     this.Sigma0256: function (x) { return (this.this.S(x, 2) ^ this.this.S(x, 13) ^ this.this.S(x, 22)); },
//     this.Sigma1256: function (x) { return (this.this.S(x, 6) ^ this.this.S(x, 11) ^ this.this.S(x, 25)); },
//     this.Gamma0256: function (x) { return (this.this.S(x, 7) ^ this.this.S(x, 18) ^ this.this.R(x, 3)); },
//     this.Gamma1256: function (x) { return (this.this.S(x, 17) ^ this.this.S(x, 19) ^ this.this.R(x, 10)); },
//     this.core_sha256: function (m, l) {
//         var K = new Array(0x428A2F98, 0x71374491, 0xB5C0FBCF, 0xE9B5DBA5, 0x3956C25B, 0x59F111F1, 0x923F82A4, 0xAB1C5ED5, 0xD807AA98, 0x12835B01, 0x243185BE, 0x550C7DC3, 0x72BE5D74, 0x80DEB1FE, 0x9BDC06A7, 0xC19BF174, 0xE49B69C1, 0xEFBE4786, 0xFC19DC6, 0x240CA1CC, 0x2DE92C6F, 0x4A7484AA, 0x5CB0A9DC, 0x76F988DA, 0x983E5152, 0xA831C66D, 0xB00327C8, 0xBF597FC7, 0xC6E00BF3, 0xD5A79147, 0x6CA6351, 0x14292967, 0x27B70A85, 0x2E1B2138, 0x4D2C6DFC, 0x53380D13, 0x650A7354, 0x766A0ABB, 0x81C2C92E, 0x92722C85, 0xA2BFE8A1, 0xA81A664B, 0xC24B8B70, 0xC76C51A3, 0xD192E819, 0xD6990624, 0xF40E3585, 0x106AA070, 0x19A4C116, 0x1E376C08, 0x2748774C, 0x34B0BCB5, 0x391C0CB3, 0x4ED8AA4A, 0x5B9CCA4F, 0x682E6FF3, 0x748F82EE, 0x78A5636F, 0x84C87814, 0x8CC70208, 0x90BEFFFA, 0xA4506CEB, 0xBEF9A3F7, 0xC67178F2);
//         var HASH = new Array(0x6A09E667, 0xBB67AE85, 0x3C6EF372, 0xA54FF53A, 0x510E527F, 0x9B05688C, 0x1F83D9AB, 0x5BE0CD19);
//         var W = new Array(64);
//         var a, b, c, d, e, f, g, h, i, j;
//         var T1, T2;
//         /* append padding */
//         m[l >> 5] |= 0x80 << (24 - l % 32);
//         m[((l + 64 >> 9) << 4) + 15] = l;
//         for (var i = 0; i < m.length; i += 16) {
//             a = HASH[0]; b = HASH[1]; c = HASH[2]; d = HASH[3]; e = HASH[4]; f = HASH[5]; g = HASH[6]; h = HASH[7];
//             for (var j = 0; j < 64; j++) {
//                 if (j < 16) W[j] = m[j + i];
//                 else W[j] = this.this.safe_add(this.this.safe_add(this.this.safe_add(this.this.Gamma1256(W[j - 2]), W[j - 7]), this.this.Gamma0256(W[j - 15])), W[j - 16]);
//                 T1 = this.this.safe_add(this.this.safe_add(this.this.safe_add(this.this.safe_add(h, this.this.Sigma1256(e)), this.this.Ch(e, f, g)), K[j]), W[j]);
//                 T2 = this.this.safe_add(this.this.Sigma0256(a), this.this.Maj(a, b, c));
//                 h = g; g = f; f = e; e = this.this.safe_add(d, T1); d = c; c = b; b = a; a = this.this.safe_add(T1, T2);
//             }
//             HASH[0] = this.this.safe_add(a, HASH[0]); HASH[1] = this.this.safe_add(b, HASH[1]); HASH[2] = this.this.safe_add(c, HASH[2]); HASH[3] = this.this.safe_add(d, HASH[3]); HASH[4] = this.this.safe_add(e, HASH[4]); HASH[5] = this.this.safe_add(f, HASH[5]); HASH[6] = this.this.safe_add(g, HASH[6]); HASH[7] = this.this.safe_add(h, HASH[7]);
//         }
//         return HASH;
//     },
//     this.str2binb: function (str) {
//         var bin = Array();
//         var mask = (1 << chrsz) - 1;
//         for (var i = 0; i < str.length * chrsz; i += chrsz)
//             bin[i >> 5] |= (str.charCodeAt(i / chrsz) & mask) << (24 - i % 32);
//         return bin;
//     },
//     this.binb2hex: function (binarray) {
//         var hexcase = 0; /* hex output format. 0 - lowercase; 1 - uppercase */
//         var hex_tab = hexcase ? "0123456789ABCDEF" : "0123456789abcdef";
//         var str = "";
//         for (var i = 0; i < binarray.length * 4; i++) {
//             str += hex_tab.charAt((binarray[i >> 2] >> ((3 - i % 4) * 8 + 4)) & 0xF) + hex_tab.charAt((binarray[i >> 2] >> ((3 - i % 4) * 8)) & 0xF);
//         }
//         return str;
//     },
//     this.hex_sha256: function (s) { return this.this.binb2hex(this.this.core_sha256(this.this.str2binb(s), s.length * chrsz)); }
// }



/* A JavaScript implementation of the Secure Hash Standard
 * Version 0.3 Copyright Angel Marin 2003-2004 - http://anmar.eu.org/
 * Distributed under the BSD License
 * Some bits taken from Paul Johnston's SHA-1 implementation
 */

var chrsz = 8;   /* bits per input character. 8 - ASCII; 16 - Unicode      */
var hexcase = 0;    /* hex output format. 0 - lowercase; 1 - uppercase        */
var b64pad = "=";  /* base-64 pad character. "=" for strict RFC compliance   */
module.exports = {
    safe_add: function (x, y) {
        var lsw = (x & 0xFFFF) + (y & 0xFFFF);
        var msw = (x >> 16) + (y >> 16) + (lsw >> 16);
        return (msw << 16) | (lsw & 0xFFFF);
    },

    S: function (X, n) { return (X >>> n) | (X << (32 - n)); },

    R: function (X, n) { return (X >>> n); },

    Ch: function (x, y, z) { return ((x & y) ^ ((~x) & z)); },

    Maj: function (x, y, z) { return ((x & y) ^ (x & z) ^ (y & z)); },

    Sigma0256: function (x) { return (this.S(x, 2) ^ this.S(x, 13) ^ this.S(x, 22)); },

    Sigma1256: function (x) { return (this.S(x, 6) ^ this.S(x, 11) ^ this.S(x, 25)); },

    Gamma0256: function (x) { return (this.S(x, 7) ^ this.S(x, 18) ^ this.R(x, 3)); },

    Gamma1256: function (x) { return (this.S(x, 17) ^ this.S(x, 19) ^ this.R(x, 10)); },

    Sigma0512: function (x) { return (this.S(x, 28) ^ this.S(x, 34) ^ this.S(x, 39)); },

    Sigma1512: function (x) { return (this.S(x, 14) ^ this.S(x, 18) ^ this.S(x, 41)); },

    Gamma0512: function (x) { return (this.S(x, 1) ^ this.S(x, 8) ^ this.R(x, 7)); },

    Gamma1512: function (x) { return (this.S(x, 19) ^ this.S(x, 61) ^ this.R(x, 6)); },

    core_sha256: function (m, l) {
        var K = new Array(0x428A2F98, 0x71374491, 0xB5C0FBCF, 0xE9B5DBA5, 0x3956C25B, 0x59F111F1, 0x923F82A4, 0xAB1C5ED5, 0xD807AA98, 0x12835B01, 0x243185BE, 0x550C7DC3, 0x72BE5D74, 0x80DEB1FE, 0x9BDC06A7, 0xC19BF174, 0xE49B69C1, 0xEFBE4786, 0xFC19DC6, 0x240CA1CC, 0x2DE92C6F, 0x4A7484AA, 0x5CB0A9DC, 0x76F988DA, 0x983E5152, 0xA831C66D, 0xB00327C8, 0xBF597FC7, 0xC6E00BF3, 0xD5A79147, 0x6CA6351, 0x14292967, 0x27B70A85, 0x2E1B2138, 0x4D2C6DFC, 0x53380D13, 0x650A7354, 0x766A0ABB, 0x81C2C92E, 0x92722C85, 0xA2BFE8A1, 0xA81A664B, 0xC24B8B70, 0xC76C51A3, 0xD192E819, 0xD6990624, 0xF40E3585, 0x106AA070, 0x19A4C116, 0x1E376C08, 0x2748774C, 0x34B0BCB5, 0x391C0CB3, 0x4ED8AA4A, 0x5B9CCA4F, 0x682E6FF3, 0x748F82EE, 0x78A5636F, 0x84C87814, 0x8CC70208, 0x90BEFFFA, 0xA4506CEB, 0xBEF9A3F7, 0xC67178F2);
        var HASH = new Array(0x6A09E667, 0xBB67AE85, 0x3C6EF372, 0xA54FF53A, 0x510E527F, 0x9B05688C, 0x1F83D9AB, 0x5BE0CD19);
        var W = new Array(64);
        var a, b, c, d, e, f, g, h, i, j;
        var T1, T2;

        /* append padding */
        m[l >> 5] |= 0x80 << (24 - l % 32);
        m[((l + 64 >> 9) << 4) + 15] = l;

        for (var i = 0; i < m.length; i += 16) {
            a = HASH[0];
            b = HASH[1];
            c = HASH[2];
            d = HASH[3];
            e = HASH[4];
            f = HASH[5];
            g = HASH[6];
            h = HASH[7];

            for (var j = 0; j < 64; j++) {
                if (j < 16) W[j] = m[j + i];
                else W[j] = this.safe_add(this.safe_add(this.safe_add(this.Gamma1256(W[j - 2]), W[j - 7]), this.Gamma0256(W[j - 15])), W[j - 16]);

                T1 = this.safe_add(this.safe_add(this.safe_add(this.safe_add(h, this.Sigma1256(e)), this.Ch(e, f, g)), K[j]), W[j]);
                T2 = this.safe_add(this.Sigma0256(a), this.Maj(a, b, c));

                h = g;
                g = f;
                f = e;
                e = this.safe_add(d, T1);
                d = c;
                c = b;
                b = a;
                a = this.safe_add(T1, T2);
            }

            HASH[0] = this.safe_add(a, HASH[0]);
            HASH[1] = this.safe_add(b, HASH[1]);
            HASH[2] = this.safe_add(c, HASH[2]);
            HASH[3] = this.safe_add(d, HASH[3]);
            HASH[4] = this.safe_add(e, HASH[4]);
            HASH[5] = this.safe_add(f, HASH[5]);
            HASH[6] = this.safe_add(g, HASH[6]);
            HASH[7] = this.safe_add(h, HASH[7]);
        }
        return HASH;
    },

    core_sha512: function (m, l) {
        var K = new Array(0x428a2f98d728ae22, 0x7137449123ef65cd, 0xb5c0fbcfec4d3b2f, 0xe9b5dba58189dbbc, 0x3956c25bf348b538, 0x59f111f1b605d019, 0x923f82a4af194f9b, 0xab1c5ed5da6d8118, 0xd807aa98a3030242, 0x12835b0145706fbe, 0x243185be4ee4b28c, 0x550c7dc3d5ffb4e2, 0x72be5d74f27b896f, 0x80deb1fe3b1696b1, 0x9bdc06a725c71235, 0xc19bf174cf692694, 0xe49b69c19ef14ad2, 0xefbe4786384f25e3, 0x0fc19dc68b8cd5b5, 0x240ca1cc77ac9c65, 0x2de92c6f592b0275, 0x4a7484aa6ea6e483, 0x5cb0a9dcbd41fbd4, 0x76f988da831153b5, 0x983e5152ee66dfab, 0xa831c66d2db43210, 0xb00327c898fb213f, 0xbf597fc7beef0ee4, 0xc6e00bf33da88fc2, 0xd5a79147930aa725, 0x06ca6351e003826f, 0x142929670a0e6e70, 0x27b70a8546d22ffc, 0x2e1b21385c26c926, 0x4d2c6dfc5ac42aed, 0x53380d139d95b3df, 0x650a73548baf63de, 0x766a0abb3c77b2a8, 0x81c2c92e47edaee6, 0x92722c851482353b, 0xa2bfe8a14cf10364, 0xa81a664bbc423001, 0xc24b8b70d0f89791, 0xc76c51a30654be30, 0xd192e819d6ef5218, 0xd69906245565a910, 0xf40e35855771202a, 0x106aa07032bbd1b8, 0x19a4c116b8d2d0c8, 0x1e376c085141ab53, 0x2748774cdf8eeb99, 0x34b0bcb5e19b48a8, 0x391c0cb3c5c95a63, 0x4ed8aa4ae3418acb, 0x5b9cca4f7763e373, 0x682e6ff3d6b2b8a3, 0x748f82ee5defb2fc, 0x78a5636f43172f60, 0x84c87814a1f0ab72, 0x8cc702081a6439ec, 0x90befffa23631e28, 0xa4506cebde82bde9, 0xbef9a3f7b2c67915, 0xc67178f2e372532b, 0xca273eceea26619c, 0xd186b8c721c0c207, 0xeada7dd6cde0eb1e, 0xf57d4f7fee6ed178, 0x06f067aa72176fba, 0x0a637dc5a2c898a6, 0x113f9804bef90dae, 0x1b710b35131c471b, 0x28db77f523047d84, 0x32caab7b40c72493, 0x3c9ebe0a15c9bebc, 0x431d67c49c100d4c, 0x4cc5d4becb3e42b6, 0x597f299cfc657e2a, 0x5fcb6fab3ad6faec, 0x6c44198c4a475817);
        var HASH = new Array(0x6a09e667f3bcc908, 0xbb67ae8584caa73b, 0x3c6ef372fe94f82b, 0xa54ff53a5f1d36f1, 0x510e527fade682d1, 0x9b05688c2b3e6c1f, 0x1f83d9abfb41bd6b, 0x5be0cd19137e2179);
        var W = new Array(80);
        var a, b, c, d, e, f, g, h, i, j;
        var T1, T2;

    },

    str2binb: function (str) {
        var bin = Array();
        var mask = (1 << chrsz) - 1;
        for (var i = 0; i < str.length * chrsz; i += chrsz)
            bin[i >> 5] |= (str.charCodeAt(i / chrsz) & mask) << (24 - i % 32);
        return bin;
    },

    binb2str: function (bin) {
        var str = "";
        var mask = (1 << chrsz) - 1;
        for (var i = 0; i < bin.length * 32; i += chrsz)
            str += String.fromCharCode((bin[i >> 5] >>> (24 - i % 32)) & mask);
        return str;
    },

    binb2hex: function (binarray) {
        var hex_tab = hexcase ? "0123456789ABCDEF" : "0123456789abcdef";
        var str = "";
        for (var i = 0; i < binarray.length * 4; i++) {
            str += hex_tab.charAt((binarray[i >> 2] >> ((3 - i % 4) * 8 + 4)) & 0xF) +
                hex_tab.charAt((binarray[i >> 2] >> ((3 - i % 4) * 8)) & 0xF);
        }
        return str;
    },

    binb2b64: function (binarray) {
        var tab = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
        var str = "";
        for (var i = 0; i < binarray.length * 4; i += 3) {
            var triplet = (((binarray[i >> 2] >> 8 * (3 - i % 4)) & 0xFF) << 16)
                | (((binarray[i + 1 >> 2] >> 8 * (3 - (i + 1) % 4)) & 0xFF) << 8)
                | ((binarray[i + 2 >> 2] >> 8 * (3 - (i + 2) % 4)) & 0xFF);
            for (var j = 0; j < 4; j++) {
                if (i * 8 + j * 6 > binarray.length * 32) str += b64pad;
                else str += tab.charAt((triplet >> 6 * (3 - j)) & 0x3F);
            }
        }
        return str;
    },

    hex_sha256: function (s) { return this.binb2hex(this.core_sha256(this.str2binb(s), s.length * chrsz)); },
    b64_sha256: function (s) { return this.binb2b64(this.core_sha256(this.str2binb(s), s.length * chrsz)); },
    str_sha256: function (s) { return this.binb2str(this.core_sha256(this.str2binb(s), s.length * chrsz)); }
}