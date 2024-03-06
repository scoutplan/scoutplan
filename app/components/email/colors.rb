# frozen_string_literal: true

# The Colors module provides a mapping from Tailwind CSS color names to their hex values.
# Let's you easily use Tailwind's colors in your emails (rather than searching for hex values).
#
# The constant's name corresponds to the TailwindCSS color variant.
# The value is the matching hex value.
# EXAMPLE: (tailwindcss)  bg-red-500             = #EF4444
#          (Colors::)     Email::Colors::RED_500 = #EF4444
#
# USAGE:
# COLOR = Email::Colors::RED_500
#
# Colors:: values are just hex string shorthands.
# These lines are the same —
# COLOR = Email::Colors::RED_500
# COLOR = "#EF4444"
#
# Using this module is _optional!_
# These values are just shorthands for hex strings.
# Anywhere you see a Colors:: value, you can pass a "#hex string" instead (and vice-versa).
# You can also add new colors to this module, and they will be available in your Email:: components.
#
# Official TailwindCSS docs — https://tailwindcss.com/docs/customizing-colors
#
module Email::Colors
  WHITE = "#FFFFFF"
  BLACK = "#000000"

  # Gray
  GRAY_50 = "#FAFAFA"
  GRAY_100 = "#F4F4F5"
  GRAY_200 = "#E4E4E7"
  GRAY_300 = "#D4D4D8"
  GRAY_400 = "#A1A1AA"
  GRAY_500 = "#71717A"
  GRAY_600 = "#52525B"
  GRAY_700 = "#3F3F46"
  GRAY_800 = "#27272A"
  GRAY_900 = "#18181B"

  # Red
  RED_50 = "#FEF2F2"
  RED_100 = "#FEE2E2"
  RED_200 = "#FECACA"
  RED_300 = "#FCA5A5"
  RED_400 = "#F87171"
  RED_500 = "#EF4444"
  RED_600 = "#DC2626"
  RED_700 = "#B91C1C"
  RED_800 = "#991B1B"
  RED_900 = "#7F1D1D"

  # Orange
  ORANGE_50 = "#FFF7ED"
  ORANGE_100 = "#FFEDD5"
  ORANGE_200 = "#FED7AA"
  ORANGE_300 = "#FDBA74"
  ORANGE_400 = "#FB923C"
  ORANGE_500 = "#F97316"
  ORANGE_600 = "#EA580C"
  ORANGE_700 = "#C2410C"
  ORANGE_800 = "#9A3412"
  ORANGE_900 = "#7C2D12"

  # Amber
  AMBER_50 = "#FFFBEB"
  AMBER_100 = "#FEF3C7"
  AMBER_200 = "#FDE68A"
  AMBER_300 = "#FCD34D"
  AMBER_400 = "#FBBF24"
  AMBER_500 = "#F59E0B"
  AMBER_600 = "#D97706"
  AMBER_700 = "#B45309"
  AMBER_800 = "#92400E"
  AMBER_900 = "#78350F"

  # Yellow
  YELLOW_50 = "#FEFCE8"
  YELLOW_100 = "#FEF9C3"
  YELLOW_200 = "#FEF08A"
  YELLOW_300 = "#FDE047"
  YELLOW_400 = "#FACC15"
  YELLOW_500 = "#EAB308"
  YELLOW_600 = "#CA8A04"
  YELLOW_700 = "#A16207"
  YELLOW_800 = "#854D0E"
  YELLOW_900 = "#713F12"

  # Lime
  LIME_50 = "#F7FEE7"
  LIME_100 = "#ECFCCB"
  LIME_200 = "#D9F99D"
  LIME_300 = "#BEF264"
  LIME_400 = "#A3E635"
  LIME_500 = "#84CC16"
  LIME_600 = "#65A30D"
  LIME_700 = "#4D7C0F"
  LIME_800 = "#3F6212"
  LIME_900 = "#365314"

  # Green
  GREEN_50 = "#F0FDF4"
  GREEN_100 = "#DCFCE7"
  GREEN_200 = "#BBF7D0"
  GREEN_300 = "#86EFAC"
  GREEN_400 = "#4ADE80"
  GREEN_500 = "#22C55E"
  GREEN_600 = "#16A34A"
  GREEN_700 = "#15803D"
  GREEN_800 = "#166534"
  GREEN_900 = "#14532D"

  # Emerald
  EMERALD_50 = "#ECFDF5"
  EMERALD_100 = "#D1FAE5"
  EMERALD_200 = "#A7F3D0"
  EMERALD_300 = "#6EE7B7"
  EMERALD_400 = "#34D399"
  EMERALD_500 = "#10B981"
  EMERALD_600 = "#059669"
  EMERALD_700 = "#047857"
  EMERALD_800 = "#065F46"
  EMERALD_900 = "#064E3B"

  # Teal
  TEAL_50 = "#F0FDFA"
  TEAL_100 = "#CCFBF1"
  TEAL_200 = "#99F6E4"
  TEAL_300 = "#5EEAD4"
  TEAL_400 = "#2DD4BF"
  TEAL_500 = "#14B8A6"
  TEAL_600 = "#0D9488"
  TEAL_700 = "#0F766E"
  TEAL_800 = "#115E59"
  TEAL_900 = "#134E4A"

  # Cyan
  CYAN_50 = "#ECFEFF"
  CYAN_100 = "#CFFAFE"
  CYAN_200 = "#A5F3FC"
  CYAN_300 = "#67E8F9"
  CYAN_400 = "#22D3EE"
  CYAN_500 = "#06B6D4"
  CYAN_600 = "#0891B2"
  CYAN_700 = "#0E7490"
  CYAN_800 = "#155E75"
  CYAN_900 = "#164E63"

  # Light Blue
  LIGHT_BLUE_50 = "#F0F9FF"
  LIGHT_BLUE_100 = "#E0F2FE"
  LIGHT_BLUE_200 = "#BAE6FD"
  LIGHT_BLUE_300 = "#7DD3FC"
  LIGHT_BLUE_400 = "#38BDF8"
  LIGHT_BLUE_500 = "#0EA5E9"
  LIGHT_BLUE_600 = "#0284C7"
  LIGHT_BLUE_700 = "#0369A1"
  LIGHT_BLUE_800 = "#075985"
  LIGHT_BLUE_900 = "#0C4A6E"

  # Blue
  BLUE_50 = "#EFF6FF"
  BLUE_100 = "#DBEAFE"
  BLUE_200 = "#BFDBFE"
  BLUE_300 = "#93C5FD"
  BLUE_400 = "#60A5FA"
  BLUE_500 = "#3B82F6"
  BLUE_600 = "#2563EB"
  BLUE_700 = "#1D4ED8"
  BLUE_800 = "#1E40AF"
  BLUE_900 = "#1E3A8A"

  # Indigo
  INDIGO_50 = "#EEF2FF"
  INDIGO_100 = "#E0E7FF"
  INDIGO_200 = "#C7D2FE"
  INDIGO_300 = "#A5B4FC"
  INDIGO_400 = "#818CF8"
  INDIGO_500 = "#6366F1"
  INDIGO_600 = "#4F46E5"
  INDIGO_700 = "#4338CA"
  INDIGO_800 = "#3730A3"
  INDIGO_900 = "#312E81"

  # Violet
  VIOLET_50 = "#F5F3FF"
  VIOLET_100 = "#EDE9FE"
  VIOLET_200 = "#DDD6FE"
  VIOLET_300 = "#C4B5FD"
  VIOLET_400 = "#A78BFA"
  VIOLET_500 = "#8B5CF6"
  VIOLET_600 = "#7C3AED"
  VIOLET_700 = "#6D28D9"
  VIOLET_800 = "#5B21B6"
  VIOLET_900 = "#4C1D95"

  # Purple
  PURPLE_50 = "#F5F3FF"
  PURPLE_100 = "#EDE9FE"
  PURPLE_200 = "#DDD6FE"
  PURPLE_300 = "#C4B5FD"
  PURPLE_400 = "#A78BFA"
  PURPLE_500 = "#8B5CF6"
  PURPLE_600 = "#7C3AED"
  PURPLE_700 = "#6D28D9"
  PURPLE_800 = "#5B21B6"
  PURPLE_900 = "#4C1D95"

  # Fuchsia
  FUCHSIA_50 = "#FDF4FF"
  FUCHSIA_100 = "#FAE8FF"
  FUCHSIA_200 = "#F5D0FE"
  FUCHSIA_300 = "#F0ABFC"
  FUCHSIA_400 = "#E879F9"
  FUCHSIA_500 = "#D946EF"
  FUCHSIA_600 = "#C026D3"
  FUCHSIA_700 = "#A21CAF"
  FUCHSIA_800 = "#86198F"
  FUCHSIA_900 = "#701A75"

  # Pink
  PINK_50 = "#FDF2F8"
  PINK_100 = "#FCE7F3"
  PINK_200 = "#FBCFE8"
  PINK_300 = "#F9A8D4"
  PINK_400 = "#F472B6"
  PINK_500 = "#EC4899"
  PINK_600 = "#DB2777"
  PINK_700 = "#BE185D"
  PINK_800 = "#9D174D"
  PINK_900 = "#831843"

  # Rose
  ROSE_50 = "#FFF1F2"
  ROSE_100 = "#FFE4E6"
  ROSE_200 = "#FECDD3"
  ROSE_300 = "#FDA4AF"
  ROSE_400 = "#FB7185"
  ROSE_500 = "#F43F5E"
  ROSE_600 = "#E11D48"
  ROSE_700 = "#BE123C"
  ROSE_800 = "#9F1239"
  ROSE_900 = "#881337"

  # Warm Gray
  WARM_GRAY_50 = "#FAFAF9"
  WARM_GRAY_100 = "#F5F5F4"
  WARM_GRAY_200 = "#E7E5E4"
  WARM_GRAY_300 = "#D6D3D1"
  WARM_GRAY_400 = "#A8A29E"
  WARM_GRAY_500 = "#78716C"
  WARM_GRAY_600 = "#57534E"
  WARM_GRAY_700 = "#44403C"
  WARM_GRAY_800 = "#292524"
  WARM_GRAY_900 = "#1C1917"

  # True Gray
  TRUE_GRAY_50 = "#FAFAFA"
  TRUE_GRAY_100 = "#F5F5F5"
  TRUE_GRAY_200 = "#E5E5E5"
  TRUE_GRAY_300 = "#D4D4D4"
  TRUE_GRAY_400 = "#A3A3A3"
  TRUE_GRAY_500 = "#737373"
  TRUE_GRAY_600 = "#525252"
  TRUE_GRAY_700 = "#404040"
  TRUE_GRAY_800 = "#262626"
  TRUE_GRAY_900 = "#171717"

  # Cool Gray
  COOL_GRAY_50 = "#F9FAFB"
  COOL_GRAY_100 = "#F3F4F6"
  COOL_GRAY_200 = "#E5E7EB"
  COOL_GRAY_300 = "#D1D5DB"
  COOL_GRAY_400 = "#9CA3AF"
  COOL_GRAY_500 = "#6B7280"
  COOL_GRAY_600 = "#4B5563"
  COOL_GRAY_700 = "#374151"
  COOL_GRAY_800 = "#1F2937"
  COOL_GRAY_900 = "#111827"

  # Blue Gray
  BLUE_GRAY_50 = "#F8FAFC"
  BLUE_GRAY_100 = "#F1F5F9"
  BLUE_GRAY_200 = "#E2E8F0"
  BLUE_GRAY_300 = "#CBD5E1"
  BLUE_GRAY_400 = "#94A3B8"
  BLUE_GRAY_500 = "#64748B"
  BLUE_GRAY_600 = "#475569"
  BLUE_GRAY_700 = "#334155"
  BLUE_GRAY_800 = "#1E293B"
  BLUE_GRAY_900 = "#0F172A"
end
