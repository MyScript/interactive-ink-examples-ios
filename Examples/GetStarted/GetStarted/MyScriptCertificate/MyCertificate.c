// Copyright MyScript. All right reserved.

//
// Replace this file with the one you received by mail when you registered as a
// developer on https://developer.myscript.com.
//

#include <stddef.h>

#ifndef VO_CERTIFICATE_TYPE
#define VO_CERTIFICATE_TYPE

/**
 * Holds a certificate.
 */
typedef struct _voCertificate
{
  /**
   * Pointer to the bytes composing the certificate.
   */
  const char* bytes;

  /**
   * Length of the certificate.
   */
  size_t length;
}
voCertificate;

#endif // end of: #ifndef VO_CERTIFICATE_TYPE

/**
 * Certificate that grants your application the right to use MyScript.
 * Usage:
 * <pre>
 *   voEngine e = voCreateEngine(VO_MSE_VER, &myCertificate, NULL);
 * </pre>
 */
voCertificate const myCertificate =
{
  NULL,
  0
};
