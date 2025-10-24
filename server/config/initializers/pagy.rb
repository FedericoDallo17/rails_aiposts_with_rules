# frozen_string_literal: true

# Pagy initializer file
# Customize only what you really need and notice that Pagy works also without any of the following lines.

require "pagy/extras/overflow"

# Default Pagy variables
Pagy::DEFAULT[:items] = 20
Pagy::DEFAULT[:overflow] = :last_page

