;; IWorkforceSync Registry
;; A decentralized marketplace for connecting individuals and organizations

;; ==================================
;; STORAGE DEFINITIONS AND CONSTANTS
;; ==================================

(define-constant ERR-NOT-FOUND (err u404))
(define-constant ERR-ALREADY-EXISTS (err u409))
(define-constant ERR-INVALID-FIELD-PRIMARY (err u400))
(define-constant ERR-INVALID-FIELD-LOCATION (err u401))


;; Registry for individual contributor information and capabilities
(define-map individual-registry
    principal
    {
        display-name: (string-ascii 100),
        capabilities: (list 10 (string-ascii 50)),
        location: (string-ascii 100),
        history: (string-ascii 500)
    }
)

;; Registry for organizational entities and their attributes
(define-map organization-registry
    principal
    {
        entity-name: (string-ascii 100),
        industry: (string-ascii 50),
        location: (string-ascii 100)
    }
)

(define-constant ERR-INVALID-FIELD-HISTORY (err u402))
(define-constant ERR-INVALID-FIELD-LISTING (err u403))
(define-constant ERR-RECORD-NOT-FOUND (err u404))


;; Registry for collaboration opportunities and project listings
(define-map collaboration-registry
    principal
    {
        title: (string-ascii 100),
        description: (string-ascii 500),
        creator: principal,
        location: (string-ascii 100),
        requirements: (list 10 (string-ascii 50))
    }
)

;; =============================
;; DATA RETRIEVAL FUNCTIONALITY
;; =============================


;; Retrieve collaboration opportunity details
(define-read-only (get-collaboration-details (listing-id principal))
    (match (map-get? collaboration-registry listing-id)
        listing-data (ok listing-data)
        ERR-NOT-FOUND
    )
)


;; ==============================
;; COLLABORATION OPPORTUNITIES
;; ==============================

;; Create a new collaboration opportunity
(define-public (create-collaboration 
    (title (string-ascii 100))
    (description (string-ascii 500))
    (location (string-ascii 100))
    (requirements (list 10 (string-ascii 50))))
    (let
        (
            (current-user tx-sender)
            (existing-listing (map-get? collaboration-registry current-user))
        )
        ;; Verify no existing listing
        (if (is-none existing-listing)
            (begin
                ;; Validate required fields
                (if (or (is-eq title "")
                        (is-eq description "")
                        (is-eq location "")
                        (is-eq (len requirements) u0))
                    (err ERR-INVALID-FIELD-LISTING)
                    (begin
                        ;; Create the collaboration listing
                        (map-set collaboration-registry current-user
                            {
                                title: title,
                                description: description,
                                creator: current-user,
                                location: location,
                                requirements: requirements
                            }
                        )
                        (ok "Collaboration opportunity successfully created.")
                    )
                )
            )
            (err ERR-ALREADY-EXISTS)
        )
    )
)

;; Update an existing collaboration opportunity
(define-public (modify-collaboration 
    (title (string-ascii 100))
    (description (string-ascii 500))
    (location (string-ascii 100))
    (requirements (list 10 (string-ascii 50))))
    (let
        (
            (current-user tx-sender)
            (existing-listing (map-get? collaboration-registry current-user))
        )
        ;; Verify listing exists
        (if (is-some existing-listing)
            (begin
                ;; Validate required fields
                (if (or (is-eq title "")
                        (is-eq description "")
                        (is-eq location "")
                        (is-eq (len requirements) u0))
                    (err ERR-INVALID-FIELD-LISTING)
                    (begin
                        ;; Update the collaboration listing
                        (map-set collaboration-registry current-user
                            {
                                title: title,
                                description: description,
                                creator: current-user,
                                location: location,
                                requirements: requirements
                            }
                        )
                        (ok "Collaboration opportunity successfully updated.")
                    )
                )
            )
            (err ERR-RECORD-NOT-FOUND)
        )
    )
)

;; Remove an existing collaboration opportunity
(define-public (remove-collaboration)
    (let
        (
            (current-user tx-sender)
            (existing-listing (map-get? collaboration-registry current-user))
        )
        ;; Verify listing exists
        (if (is-some existing-listing)
            (begin
                ;; Remove the collaboration listing
                (map-delete collaboration-registry current-user)
                (ok "Collaboration opportunity successfully removed.")
            )
            (err ERR-RECORD-NOT-FOUND)
        )
    )
)

;; ================================
;; INDIVIDUAL PROFILE MANAGEMENT
;; ================================

;; Register a new individual contributor profile
(define-public (register-individual 
    (display-name (string-ascii 100))
    (capabilities (list 10 (string-ascii 50)))
    (location (string-ascii 100))
    (history (string-ascii 500)))
    (let
        (
            (current-user tx-sender)
            (existing-profile (map-get? individual-registry current-user))
        )
        ;; Verify no existing profile for this user
        (if (is-none existing-profile)
            (begin
                ;; Validate required information
                (if (or (is-eq display-name "")
                        (is-eq location "")
                        (is-eq (len capabilities) u0)
                        (is-eq history ""))
                    (err ERR-INVALID-FIELD-HISTORY)
                    (begin
                        ;; Create the individual profile
                        (map-set individual-registry current-user
                            {
                                display-name: display-name,
                                capabilities: capabilities,
                                location: location,
                                history: history
                            }
                        )
                        (ok "Individual profile successfully registered.")
                    )
                )
            )
            (err ERR-ALREADY-EXISTS)
        )
    )
)

;; Modify an existing individual contributor profile
(define-public (modify-individual-profile 
    (display-name (string-ascii 100))
    (capabilities (list 10 (string-ascii 50)))
    (location (string-ascii 100))
    (history (string-ascii 500)))
    (let
        (
            (current-user tx-sender)
            (existing-profile (map-get? individual-registry current-user))
        )
        ;; Verify profile exists
        (if (is-some existing-profile)
            (begin
                ;; Validate required information
                (if (or (is-eq display-name "")
                        (is-eq location "")
                        (is-eq (len capabilities) u0)
                        (is-eq history ""))
                    (err ERR-INVALID-FIELD-HISTORY)
                    (begin
                        ;; Update the individual profile
                        (map-set individual-registry current-user
                            {
                                display-name: display-name,
                                capabilities: capabilities,
                                location: location,
                                history: history
                            }
                        )
                        (ok "Individual profile successfully updated.")
                    )
                )
            )
            (err ERR-RECORD-NOT-FOUND)
        )
    )
)

;; Remove an individual contributor profile
(define-public (deregister-individual)
    (let
        (
            (current-user tx-sender)
            (existing-profile (map-get? individual-registry current-user))
        )
        ;; Verify profile exists
        (if (is-some existing-profile)
            (begin
                ;; Remove the individual profile
                (map-delete individual-registry current-user)
                (ok "Individual profile successfully deregistered.")
            )
            (err ERR-RECORD-NOT-FOUND)
        )
    )
)

;; ================================
;; ORGANIZATION PROFILE MANAGEMENT
;; ================================

;; Register a new organizational entity
(define-public (register-organization 
    (entity-name (string-ascii 100))
    (industry (string-ascii 50))
    (location (string-ascii 100)))
    (let
        (
            (current-user tx-sender)
            (existing-profile (map-get? organization-registry current-user))
        )
        ;; Verify no existing profile
        (if (is-none existing-profile)
            (begin
                ;; Validate required fields
                (if (or (is-eq entity-name "")
                        (is-eq industry "")
                        (is-eq location ""))
                    (err ERR-INVALID-FIELD-LOCATION)
                    (begin
                        ;; Create organization profile
                        (map-set organization-registry current-user
                            {
                                entity-name: entity-name,
                                industry: industry,
                                location: location
                            }
                        )
                        (ok "Organization profile successfully registered.")
                    )
                )
            )
            (err ERR-ALREADY-EXISTS)
        )
    )
)

;; Modify an existing organizational entity
(define-public (modify-organization-profile 
    (entity-name (string-ascii 100))
    (industry (string-ascii 50))
    (location (string-ascii 100)))
    (let
        (
            (current-user tx-sender)
            (existing-profile (map-get? organization-registry current-user))
        )
        ;; Verify profile exists
        (if (is-some existing-profile)
            (begin
                ;; Validate required fields
                (if (or (is-eq entity-name "")
                        (is-eq industry "")
                        (is-eq location ""))
                    (err ERR-INVALID-FIELD-LOCATION)
                    (begin
                        ;; Update organization profile
                        (map-set organization-registry current-user
                            {
                                entity-name: entity-name,
                                industry: industry,
                                location: location
                            }
                        )
                        (ok "Organization profile successfully updated.")
                    )
                )
            )
            (err ERR-RECORD-NOT-FOUND)
        )
    )
)

;; Remove an organizational entity
(define-public (deregister-organization)
    (let
        (
            (current-user tx-sender)
            (existing-profile (map-get? organization-registry current-user))
        )
        ;; Verify profile exists
        (if (is-some existing-profile)
            (begin
                ;; Remove the organization profile
                (map-delete organization-registry current-user)
                (ok "Organization profile successfully deregistered.")
            )
            (err ERR-RECORD-NOT-FOUND)
        )
    )
)


