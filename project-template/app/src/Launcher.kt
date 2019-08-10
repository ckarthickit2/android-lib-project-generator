package templatepackage

import android.os.Bundle
import android.widget.TextView
import androidx.appcompat.app.AppCompatActivity
import templatepackage.templateapp.R
import templatepackage.TemplateLibraryInfo

class Launcher : AppCompatActivity() {

  private lateinit var label: TextView
  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    setContentView(R.layout.activity_launcher)
    initViews()
    setupViews()
  }

  private fun initViews() {
    label = findViewById(R.id.label)
  }

  private fun setupViews() {
    label.text = getString(R.string.welcome_message, TemplateLibraryInfo.VERSION_SLASHY)
  }
}
