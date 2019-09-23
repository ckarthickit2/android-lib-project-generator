package templatepackage

import org.junit.jupiter.api.Assertions
import org.junit.jupiter.api.Nested
import org.junit.jupiter.api.Test

internal class TemplateLibraryInfoTest {

  @Nested
  inner class TemplateLibraryInfoPropertiesTest {

    @Test
    fun `check integer version`() {
      val majorVersionStr = when {
        TemplateLibraryInfo.MAJOR_VERSION < 10 -> "00${TemplateLibraryInfo.MAJOR_VERSION}"
        TemplateLibraryInfo.MAJOR_VERSION < 100 -> "0${TemplateLibraryInfo.MAJOR_VERSION}"
        else -> "${TemplateLibraryInfo.MAJOR_VERSION}"
      }
      val minorVersionStr = when {
        TemplateLibraryInfo.MINOR_VERSION < 10 -> "00${TemplateLibraryInfo.MINOR_VERSION}"
        TemplateLibraryInfo.MINOR_VERSION < 100 -> "0${TemplateLibraryInfo.MINOR_VERSION}"
        else -> "${TemplateLibraryInfo.MINOR_VERSION}"
      }
      val patchVersionStr = when {
        TemplateLibraryInfo.PATCH_VERSION < 10 -> "00${TemplateLibraryInfo.PATCH_VERSION}"
        TemplateLibraryInfo.PATCH_VERSION < 100 -> "0${TemplateLibraryInfo.PATCH_VERSION}"
        else -> "${TemplateLibraryInfo.PATCH_VERSION}"
      }
      Assertions.assertEquals(
        Integer.parseInt("$majorVersionStr$minorVersionStr$patchVersionStr"),
        TemplateLibraryInfo.VERSION_INT
      )
    }

    @Test
    fun `computed properties should not be null`() {
      Assertions.assertNotNull(TemplateLibraryInfo.VERSION_SLASHY)
      Assertions.assertNotNull(TemplateLibraryInfo.VERSION)
      Assertions.assertNotNull(TemplateLibraryInfo.VERSION_INT)
    }

  }

  @Nested
  inner class TemplateLibraryInfoJavaClassTest {
    @Test
    fun `check Template library class info`() {
      Assertions.assertNotNull(TemplateLibraryInfo::class.java)
      Assertions.assertNotNull(TemplateLibraryInfo.toString())
    }
  }

}
