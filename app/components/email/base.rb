# frozen_string_literal: true

require_relative "colors"

# Email::Base defines default styles for every other component.
# All other components inherit from Email::Base
# Each nested class represents a different component, and contains constants for its default styles.
# You can override these defaults! Adjust them to suit your visual style.
# See the end of this file for dark variant options.
#
class Email::Base < ViewComponent::Base
  # TailwindCSS color mappings (see colors.rb)
  # Ex: Email::Colors::GRAY_200 = #E4E4E7
  include Email::Colors

  # Email::Container default styles
  #
  class ContainerStyles
    # You can customize the default font for your email (overridable for individual components).
    # For maximum compatibility, only these 6 email-safe fonts should be used.
    # You can try other fonts (specify a :lowercase_symbol, like :tahoma), but they WILL break on some email clients.
    # If for some reason, we still can't load a safe font, FALLBACK_FONT will be used instead.
    #
    # Supported fonts (DEFAULT_FONT):
    # - (sans serif): :arial, :trebuchet_ms, :verdana
    # - (serif): :courier_new, :georgia, :times_new_roman
    #
    # Supported fonts (FALLBACK_FONT):
    # - :sans_serif, :serif
    #
    DEFAULT_FONT = :arial
    FALLBACK_FONT = :sans_serif

    COLOR = Email::Colors::WHITE # [dark variant available]
    SURROUNDS_COLOR = Email::Colors::GRAY_200 # [dark variant available]
    BORDER_RADIUS = "16px"
    PADDING = "25px"
  end

  # Email::ResetStylesheet default styles
  #
  class ResetStylesheetStyles
    LINK_COLOR = Email::Colors::RED_500
    LINK_TEXT_DECORATION = "underline"
  end

  # Email::Text default styles
  # Also a base for other default styles (ie: heading text color)
  #
  class TextStyles
    FONT = ContainerStyles::DEFAULT_FONT
    FALLBACK_FONT = ContainerStyles::FALLBACK_FONT

    SIZE = "16px"
    COLOR = Email::Colors::GRAY_900 # [dark variant available]
  end

  # Email::Heading default styles
  #
  class HeadingStyles
    FONT = TextStyles::FONT
    FALLBACK_FONT = TextStyles::FALLBACK_FONT

    SIZE = "24px"
    COLOR = TextStyles::COLOR
  end

  # Email::Button default styles
  #
  class ButtonStyles
    FONT = TextStyles::FONT
    FALLBACK_FONT = TextStyles::FALLBACK_FONT

    BACKGROUND_COLOR = Email::Colors::RED_500 # [dark variant available]
    TEXT_SIZE = "16px"
    TEXT_COLOR = Email::Colors::RED_50 # [dark variant available]
    WIDTH = "18px"
    HEIGHT = "10px"
    BORDER_RADIUS = "8px"
    SHADOW = "0 2px 3px rgba(0, 0, 0, 0.16)"
  end

  # Email::Colorblock default styles
  #
  class ColorblockStyles
    BACKGROUND_COLOR = Email::Colors::GRAY_50 # [dark variant available]
    BORDER_COLOR = Email::Colors::GRAY_300 # [dark variant available]
    BORDER_WIDTH = "4px"
    BORDER_RADIUS = "16px"
    BORDER_STYLE = "solid"
    MARGIN = "48px auto"
    PADDING = "32px"
  end

  # Email::Divider default styles
  #
  class DividerStyles
    WIDTH = "100%"
    COLOR = Email::Colors::GRAY_100
    THICKNESS = "1px"
  end

  # Email::Footer default styles
  #
  class FooterStyles
    FONT = TextStyles::FONT
    FALLBACK_FONT = TextStyles::FALLBACK_FONT

    PADDING = "35px"
    TEXT_SIZE = TextStyles::SIZE
    TEXT_COLOR = TextStyles::COLOR
    TEXT_ALIGN = "center"
  end

  # Email::InvoiceTable default styles (and for all related invoice components)
  #
  class InvoiceTableStyles
    FONT = TextStyles::FONT
    FALLBACK_FONT = TextStyles::FALLBACK_FONT

    HEADER_TEXT_COLOR = TextStyles::COLOR
    ROW_HEADER_TEXT_COLOR = Email::Colors::GRAY_400
    ROW_TEXT_COLOR = TextStyles::COLOR
    TOTAL_TEXT_COLOR = TextStyles::COLOR
  end

  # Email::MastheadText default styles
  #
  class MastheadTextStyles
    FONT = TextStyles::FONT
    FALLBACK_FONT = TextStyles::FALLBACK_FONT

    COLOR = TextStyles::COLOR
    TEXT_SHADOW = "0 1px 0 white"
  end

  # Styles for dark mode rendering
  # NOTE: These styles can _only_ be configured here (due to how we handle media queries).
  #       You can't adjust the dark mode display for individual elements.
  class DarkStyles
    # whether dark mode media queries are included in your emails
    # set this false to disable dark mode
    # useful if your mailer templates use dark colors even in "light" mode
    ENABLED = true

    # Email::Container
    CONTAINER_COLOR = Email::Colors::GRAY_800
    CONTAINER_SURROUNDS_COLOR = Email::Colors::GRAY_900
    CONTAINER_TEXT_COLOR = Email::Colors::GRAY_100

    # Email::Button
    BUTTON_COLOR = Email::Colors::GRAY_100
    BUTTON_TEXT_COLOR = Email::Colors::GRAY_900

    # Email::Colorblock
    COLORBLOCK_COLOR = Email::Colors::GRAY_900
  end
end
