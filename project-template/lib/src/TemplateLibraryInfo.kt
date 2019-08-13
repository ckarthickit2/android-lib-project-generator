// @file:JvmName("TemplateLibraryInfo")

package templatepackage

/**
 * Information about the library such as version and name.
 */
object TemplateLibraryInfo {

  /**
   * The Major version of the library
   */
  @SuppressWarnings("unused")
  const val MAJOR_VERSION: Int = 1
  /**
   * The Minor version of the library
   */
  @SuppressWarnings("unused")
  const val MINOR_VERSION: Int = 0
  /**
   * The Path version of the library
   */
  @SuppressWarnings("unused")
  const val PATCH_VERSION: Int = 0

  /**
   * The version of the library expressed as a string, for example "1.2.3".
   */
  @SuppressWarnings("unused")
  const val VERSION: String = "$MAJOR_VERSION.$MINOR_VERSION.$PATCH_VERSION"

  /**
   * The version of the library expressed as {@code "Template/" + VERSION}.
   */
  @SuppressWarnings("unused")
  const val VERSION_SLASHY: String = "Template/$VERSION"

  /**
   * The version of the library expressed as an integer, for example 1002003.
   *
   * Three digits are used for each component of [VERSION]. For example "1.2.3" has the
   * corresponding integer version 1002003 (001-002-003), and "123.45.6" has the corresponding
   * integer version 123045006 (123-045-006).
   */
  @SuppressWarnings("unused")
  const val VERSION_INT: Int = (MAJOR_VERSION * 1000 * 1000) + (MINOR_VERSION * 1000) + PATCH_VERSION
}
