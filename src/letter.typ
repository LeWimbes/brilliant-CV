/*
 * Functions for the cover letter template
 */

#import "./cv.typ": _cv-header
#import "./utils/styles.typ": _awesome-colors, _set-accent-color
#import "./utils/injection.typ": _inject

/// Create letter style functions shared by both header styles.
/// -> dictionary
#let _letter-styles(accent-color, address-style) = (
  name: str => text(fill: accent-color, weight: "bold", str),
  address: str => {
    if address-style == "smallcaps" {
      text(fill: gray, size: 0.9em, smallcaps(str))
    } else {
      text(fill: gray, size: 0.9em, str)
    }
  },
  date: str => text(size: 0.9em, style: "italic", str),
  subject: str => text(fill: accent-color, weight: "bold", underline(str)),
)

/// Classic letter header: sender name and postal address, right-aligned recipient block, date, subject.
/// -> content
#let _letter-header-classic(
  sender-name,
  sender-address,
  recipient-name,
  recipient-address,
  date,
  subject,
  styles,
) = {
  (styles.name)(sender-name)
  v(1pt)
  (styles.address)(sender-address)
  v(1pt)
  align(right, (styles.name)(recipient-name))
  v(1pt)
  align(right, (styles.address)(recipient-address))
  v(1pt)
  (styles.date)(date)
  v(1pt)
  (styles.subject)(subject)
  linebreak()
  linebreak()
}

/// CV-style letter header: the CV header followed by a left-aligned recipient / date / subject block.
/// The sender's postal address is not rendered.
/// -> content
#let _letter-header-cv(
  metadata,
  profile-photo,
  header-font,
  regular-colors,
  awesome-colors,
  custom-icons,
  recipient-name,
  recipient-address,
  date,
  subject,
  styles,
) = {
  _cv-header(
    metadata,
    profile-photo,
    header-font,
    regular-colors,
    awesome-colors,
    custom-icons,
  )
  v(6mm)
  (styles.name)(recipient-name)
  linebreak()
  (styles.address)(recipient-address)
  v(6mm)
  (styles.date)(date)
  v(6mm)
  (styles.subject)(subject)
  v(6mm)
}

/// Dispatch to the header style selected by [layout.letter] header_style.
/// -> content
#let _letter-header(
  sender-address: "Your Address Here",
  recipient-name: "Company Name Here",
  recipient-address: "Company Address Here",
  date: "Today's Date",
  subject: "Subject: Hey!",
  metadata: metadata,
  profile-photo: none,
  header-font: none,
  regular-colors: none,
  awesome-colors: _awesome-colors,
  custom-icons: (:),
  header-style: "classic",
  address-style: "smallcaps",
) = {
  let accent-color = _set-accent-color(awesome-colors, metadata)
  let styles = _letter-styles(accent-color, address-style)

  if header-style == "cv" {
    _letter-header-cv(
      metadata,
      profile-photo,
      header-font,
      regular-colors,
      awesome-colors,
      custom-icons,
      recipient-name,
      recipient-address,
      date,
      subject,
      styles,
    )
  } else {
    // Keyword injection (consistent with CV)
    let inject = metadata.at("inject", default: (:))
    let custom-ai-prompt-text = inject.at(
      "custom_ai_prompt_text",
      default: none,
    )
    let keywords = inject.at("injected_keywords_list", default: ())
    _inject(
      custom-ai-prompt-text: custom-ai-prompt-text,
      keywords: keywords,
    )

    let sender-name = (
      metadata.personal.first_name + " " + metadata.personal.last_name
    )
    _letter-header-classic(
      sender-name,
      sender-address,
      recipient-name,
      recipient-address,
      date,
      subject,
      styles,
    )
  }
}

#let _letter-signature(img) = {
  set image(width: 25%)
  linebreak()
  place(right, dx: -5%, dy: 0%, img)
}

#let _letter-footer(metadata) = {
  // Parameters
  let sender-name = (
    metadata.personal.first_name + " " + metadata.personal.last_name
  )
  let letter-footer-text = metadata.at("letter_footer", default: "")
  let display-footer = metadata.layout.at("footer", default: {}).at("display_footer", default: true)

  if not display-footer {
    return none
  }

  // Styles
  let footer-style(str) = {
    text(size: 8pt, fill: rgb("#999999"), smallcaps(str))
  }

  table(
    columns: (1fr, auto),
    inset: 0pt,
    stroke: none,
    footer-style([#sender-name]), footer-style(letter-footer-text),
  )
}
