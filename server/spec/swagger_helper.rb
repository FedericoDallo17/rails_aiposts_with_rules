# frozen_string_literal: true

require "rails_helper"

RSpec.configure do |config|
  # Specify a root folder where Swagger JSON files are generated
  # NOTE: If you're using the rswag-api to serve API descriptions, you'll need
  # to ensure that it's configured, as the install generator no longer runs this for you
  config.openapi_root = Rails.root.join("swagger").to_s

  # Define one or more Swagger documents and provide global metadata for each one
  # When you run the 'rswag:specs:swaggerize' rake task, the complete Swagger will
  # be generated at the provided relative path under openapi_root
  # By default, the operations defined in spec files are added to the first
  # document below. You can override this behavior by adding a openapi_spec tag to the
  # the root example_group in your specs, e.g. describe '...', openapi_spec: 'v2/swagger.json'
  config.openapi_specs = {
    "v1/swagger.yaml" => {
      openapi: "3.0.1",
      info: {
        title: "AIPosts API V1",
        version: "v1",
        description: "Una API completa de red social con posts, comentarios, likes, seguimientos y notificaciones en tiempo real."
      },
      paths: {},
      servers: [
        {
          url: "http://localhost:3000",
          description: "Development server"
        },
        {
          url: "https://api.aiposts.com",
          description: "Production server"
        }
      ],
      components: {
        securitySchemes: {
          bearerAuth: {
            type: :http,
            scheme: :bearer,
            bearerFormat: "JWT"
          }
        },
        schemas: {
          User: {
            type: :object,
            properties: {
              id: {type: :integer},
              email: {type: :string},
              username: {type: :string},
              first_name: {type: :string},
              last_name: {type: :string},
              full_name: {type: :string},
              bio: {type: :string},
              website: {type: :string},
              location: {type: :string},
              profile_picture_url: {type: :string, nullable: true},
              cover_picture_url: {type: :string, nullable: true},
              followers_count: {type: :integer},
              following_count: {type: :integer},
              posts_count: {type: :integer},
              created_at: {type: :string, format: "date-time"},
              updated_at: {type: :string, format: "date-time"}
            },
            required: ["id", "email", "username"]
          },
          Post: {
            type: :object,
            properties: {
              id: {type: :integer},
              content: {type: :string},
              tags: {type: :array, items: {type: :string}},
              likes_count: {type: :integer},
              comments_count: {type: :integer},
              created_at: {type: :string, format: "date-time"},
              updated_at: {type: :string, format: "date-time"},
              user: {"$ref" => "#/components/schemas/User"},
              liked_by_current_user: {type: :boolean}
            },
            required: ["id", "content", "user"]
          },
          Comment: {
            type: :object,
            properties: {
              id: {type: :integer},
              content: {type: :string},
              created_at: {type: :string, format: "date-time"},
              updated_at: {type: :string, format: "date-time"},
              user: {"$ref" => "#/components/schemas/User"},
              post_id: {type: :integer}
            },
            required: ["id", "content", "user", "post_id"]
          },
          Notification: {
            type: :object,
            properties: {
              id: {type: :integer},
              event_type: {type: :string, enum: ["like", "comment", "follow", "mention"]},
              read_at: {type: :string, format: "date-time", nullable: true},
              created_at: {type: :string, format: "date-time"},
              notifiable_type: {type: :string},
              notifiable_id: {type: :integer},
              notifiable: {type: :object}
            },
            required: ["id", "event_type", "notifiable_type", "notifiable_id"]
          },
          Error: {
            type: :object,
            properties: {
              error: {type: :string},
              errors: {type: :array, items: {type: :string}}
            }
          }
        }
      }
    }
  }

  # Specify the format of the output Swagger file when running 'rswag:specs:swaggerize'.
  # The openapi_specs configuration option has the filename including format in
  # the key, this may want to be changed to avoid putting yaml in json files.
  # Defaults to json. Accepts ':json' and ':yaml'.
  config.openapi_format = :yaml
end

