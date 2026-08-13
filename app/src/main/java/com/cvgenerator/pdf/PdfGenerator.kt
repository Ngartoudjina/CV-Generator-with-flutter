package com.cvgenerator.pdf

import android.content.Context
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.graphics.pdf.PdfDocument
import com.cvgenerator.data.CvData
import java.io.File

object PdfGenerator {

    fun generate(context: Context, cvData: CvData): File {
        val pageWidth = 595   // A4 width in points (72dpi)
        val pageHeight = 842  // A4 height in points

        val pdfDocument = PdfDocument()
        val pageInfo = PdfDocument.PageInfo.Builder(pageWidth, pageHeight, 1).create()
        val page = pdfDocument.startPage(pageInfo)
        val canvas = page.canvas

        drawCv(canvas, cvData, pageWidth, pageHeight)

        pdfDocument.finishPage(page)

        val file = File(context.getExternalFilesDir(null), "CV_${cvData.personalInfo.fullName.replace(" ", "_")}.pdf")
        pdfDocument.writeTo(file.outputStream())
        pdfDocument.close()

        return file
    }

    private fun drawCv(canvas: Canvas, cvData: CvData, width: Int, height: Int) {
        val info = cvData.personalInfo
        val margin = 40f
        var y = 0f

        // Header background
        val headerPaint = Paint().apply { color = Color.parseColor("#0A0A0F") }
        canvas.drawRect(0f, 0f, width.toFloat(), 120f, headerPaint)

        // Name
        val namePaint = Paint().apply {
            color = Color.parseColor("#F5F2ED")
            textSize = 22f
            isFakeBoldText = true
            isAntiAlias = true
        }
        canvas.drawText(info.fullName.ifBlank { "Votre Nom" }, margin, 45f, namePaint)

        // Job title
        val titlePaint = Paint().apply {
            color = Color.parseColor("#C8A96E")
            textSize = 14f
            isAntiAlias = true
        }
        canvas.drawText(info.jobTitle.ifBlank { "" }, margin, 68f, titlePaint)

        // Contact info
        val contactPaint = Paint().apply {
            color = Color.parseColor("#AAAAAA")
            textSize = 10f
            isAntiAlias = true
        }
        val contacts = listOfNotNull(
            info.email.takeIf { it.isNotBlank() },
            info.phone.takeIf { it.isNotBlank() },
            info.city.takeIf { it.isNotBlank() }
        ).joinToString("  ·  ")
        canvas.drawText(contacts, margin, 90f, contactPaint)

        y = 140f

        // Summary
        if (info.summary.isNotBlank()) {
            y = drawSection(canvas, "PROFIL", y, margin, width)
            y = drawWrappedText(canvas, info.summary, margin, y, width - margin * 2, 11f, Color.parseColor("#333333"))
            y += 16f
        }

        // Experiences
        if (cvData.experiences.isNotEmpty()) {
            y = drawSection(canvas, "EXPÉRIENCES", y, margin, width)
            cvData.experiences.forEach { exp ->
                val boldPaint = Paint().apply { color = Color.parseColor("#111111"); textSize = 12f; isFakeBoldText = true; isAntiAlias = true }
                val subPaint = Paint().apply { color = Color.parseColor("#555555"); textSize = 11f; isAntiAlias = true }
                val datePaint = Paint().apply { color = Color.parseColor("#888888"); textSize = 10f; isAntiAlias = true }

                canvas.drawText(exp.position, margin, y, boldPaint)
                val dateStr = "${exp.startDate} — ${if (exp.isCurrent) "Présent" else exp.endDate}"
                canvas.drawText(dateStr, width - margin - datePaint.measureText(dateStr), y, datePaint)
                y += 16f
                canvas.drawText(exp.company, margin, y, subPaint)
                y += 14f
                if (exp.description.isNotBlank()) {
                    y = drawWrappedText(canvas, exp.description, margin, y, width - margin * 2, 10f, Color.parseColor("#555555"))
                }
                y += 10f
            }
        }

        // Education
        if (cvData.educations.isNotEmpty()) {
            y = drawSection(canvas, "FORMATION", y, margin, width)
            cvData.educations.forEach { edu ->
                val boldPaint = Paint().apply { color = Color.parseColor("#111111"); textSize = 12f; isFakeBoldText = true; isAntiAlias = true }
                val subPaint = Paint().apply { color = Color.parseColor("#555555"); textSize = 11f; isAntiAlias = true }

                canvas.drawText(edu.degree, margin, y, boldPaint)
                y += 16f
                canvas.drawText("${edu.school}${if (edu.field.isNotBlank()) " · ${edu.field}" else ""}", margin, y, subPaint)
                y += 14f
            }
            y += 6f
        }

        // Skills
        if (cvData.skills.isNotEmpty()) {
            y = drawSection(canvas, "COMPÉTENCES", y, margin, width)
            val skillPaint = Paint().apply { color = Color.parseColor("#333333"); textSize = 11f; isAntiAlias = true }
            val barBg = Paint().apply { color = Color.parseColor("#DDDDDD") }
            val barFg = Paint().apply { color = Color.parseColor("#C8A96E") }

            val barWidth = (width - margin * 2 - 20f) / 2
            cvData.skills.chunked(2).forEach { row ->
                row.forEachIndexed { i, skill ->
                    val x = margin + i * (barWidth + 20f)
                    canvas.drawText(skill.name, x, y, skillPaint)
                    canvas.drawRect(x, y + 4f, x + barWidth, y + 9f, barBg)
                    canvas.drawRect(x, y + 4f, x + barWidth * skill.level.value, y + 9f, barFg)
                }
                y += 24f
            }
            y += 6f
        }

        // Languages
        if (cvData.languages.isNotEmpty()) {
            y = drawSection(canvas, "LANGUES", y, margin, width)
            val langPaint = Paint().apply { color = Color.parseColor("#333333"); textSize = 11f; isAntiAlias = true }
            val langText = cvData.languages.joinToString("   ·   ") { "${it.name} — ${it.level}" }
            canvas.drawText(langText, margin, y, langPaint)
        }
    }

    private fun drawSection(canvas: Canvas, title: String, y: Float, margin: Float, width: Int): Float {
        val titlePaint = Paint().apply {
            color = Color.parseColor("#C8A96E")
            textSize = 9f
            isFakeBoldText = true
            letterSpacing = 0.15f
            isAntiAlias = true
        }
        val linePaint = Paint().apply { color = Color.parseColor("#C8A96E"); strokeWidth = 0.8f }

        canvas.drawText(title, margin, y, titlePaint)
        canvas.drawLine(margin, y + 5f, (width - margin), y + 5f, linePaint)
        return y + 18f
    }

    private fun drawWrappedText(canvas: Canvas, text: String, x: Float, startY: Float, maxWidth: Float, size: Float, color: Int): Float {
        val paint = Paint().apply { this.color = color; textSize = size; isAntiAlias = true }
        var y = startY
        val words = text.split(" ")
        var line = ""
        words.forEach { word ->
            val test = if (line.isEmpty()) word else "$line $word"
            if (paint.measureText(test) > maxWidth) {
                canvas.drawText(line, x, y, paint)
                y += size + 4f
                line = word
            } else {
                line = test
            }
        }
        if (line.isNotEmpty()) {
            canvas.drawText(line, x, y, paint)
            y += size + 4f
        }
        return y
    }
}
