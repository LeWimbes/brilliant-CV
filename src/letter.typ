/*
 * Functions for the cover letter template
 */

#import "./cv.typ": _cv-header
#import "./utils/styles.typ": _awesome-colors, _set-accent-color
#import "./utils/injection.typ": _inject
#import "./utils/parts.typ": _part, _resolve-parts
#import "./utils/identity.typ": _display-name

/// Create letter style functions shared by both header styles.
/// -> dictionary
#let _letter-styles(metadata, accent-color, address-style) = {
  let parts = _resolve-parts(metadata)
  (
    name: (part, str) => _part(
      part,
      (fill: accent-color, weight: "bold"),
      parts,
      str,
    ),
    address: (part, str) => _part(
      part,
      (fill: gray, size: 0.9em),
      parts,
      if address-style == "smallcaps" { smallcaps(str) } else { str },
    ),
    date: str => _part(
      "letter-date",
      (size: 0.9em, style: "italic"),
      parts,
      str,
    ),
    subject: str => _part(
      "letter-subject",
      (fill: accent-color, weight: "bold"),
      parts,
      underline(str),
    ),
  )
}

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
  (styles.name)("letter-sender-name", sender-name)
  v(1pt)
  (styles.address)("letter-sender-address", sender-address)
  v(1pt)
  align(right, (styles.name)("letter-recipient-name", recipient-name))
  v(1pt)
  align(right, (styles.address)(
    "letter-recipient-address",
    recipient-address,
  ))
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
    auto,
  )
  v(6mm)
  (styles.name)("letter-recipient-name", recipient-name)
  linebreak()
  (styles.address)("letter-recipient-address", recipient-address)
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
  let styles = _letter-styles(metadata, accent-color, address-style)

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

    let sender-name = _display-name(metadata)
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
  // Keep the signature in the flow so it reserves its height: a placed
  // signature took no space and ran into the footer, or off the page, when
  // the body filled the page. An unbreakable block moves to the next page
  // instead.
  block(breakable: false, above: 0pt, width: 100%, align(right, move(
    dx: -5%,
    img,
  )))
}

#let _letter-footer(metadata) = {
  // Parameters
  let sender-name = _display-name(metadata)
  let letter-footer-text = metadata.at("letter_footer", default: "")
  let display-footer = metadata
    .layout
    .at("footer", default: {})
    .at("display_footer", default: true)

  if not display-footer {
    return none
  }

  // Styles
  let parts = _resolve-parts(metadata)
  let footer-style(str) = _part(
    "footer",
    (size: 8pt, fill: rgb("#999999")),
    parts,
    smallcaps(str),
  )

  grid(
    columns: (1fr, auto),
    inset: 0pt,
    stroke: none,
    footer-style([#sender-name]), footer-style(letter-footer-text),
  )
}
