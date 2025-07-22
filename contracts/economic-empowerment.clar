;; Economic Empowerment Contract
;; Provides financial assistance and job training for survivors

;; Constants
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-NOT-AUTHORIZED (err u400))
(define-constant ERR-INVALID-INPUT (err u401))
(define-constant ERR-INSUFFICIENT-FUNDS (err u402))
(define-constant ERR-GRANT-NOT-FOUND (err u403))
(define-constant ERR-PROGRAM-NOT-FOUND (err u404))

;; Grant types
(define-constant GRANT-EMERGENCY u1)
(define-constant GRANT-HOUSING u2)
(define-constant GRANT-EDUCATION u3)
(define-constant GRANT-CHILDCARE u4)
(define-constant GRANT-BUSINESS u5)

;; Program types
(define-constant PROGRAM-JOB-TRAINING u1)
(define-constant PROGRAM-EDUCATION u2)
(define-constant PROGRAM-FINANCIAL-LITERACY u3)
(define-constant PROGRAM-ENTREPRENEURSHIP u4)

;; Status types
(define-constant STATUS-PENDING u1)
(define-constant STATUS-APPROVED u2)
(define-constant STATUS-DENIED u3)
(define-constant STATUS-COMPLETED u4)
(define-constant STATUS-ACTIVE u5)

;; Data structures
(define-map financial-grants
  { grant-id: uint }
  {
    survivor-id: (buff 32),
    grant-type: uint,
    amount: uint,
    status: uint,
    application-date: uint,
    approval-date: uint,
    disbursement-date: uint,
    purpose: (buff 128),
    milestones: (list 5 uint)
  }
)

(define-map training-programs
  { program-id: uint }
  {
    program-name: (buff 64),
    program-type: uint,
    duration-weeks: uint,
    max-participants: uint,
    current-participants: uint,
    skills-taught: (list 10 uint),
    certification-offered: bool,
    job-placement-rate: uint
  }
)

(define-map program-enrollments
  { enrollment-id: uint }
  {
    survivor-id: (buff 32),
    program-id: uint,
    enrollment-date: uint,
    completion-date: uint,
    status: uint,
    progress-percentage: uint,
    employment-outcome: bool
  }
)

(define-map authorized-coordinators principal bool)
(define-map survivor-grants (buff 32) (list 20 uint))

;; Data variables
(define-data-var next-grant-id uint u1)
(define-data-var next-program-id uint u1)
(define-data-var next-enrollment-id uint u1)
(define-data-var total-fund-balance uint u0)

;; Authorization functions
(define-public (authorize-coordinator (coordinator principal))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (ok (map-set authorized-coordinators coordinator true))
  )
)

(define-public (deposit-funds (amount uint))
  (begin
    (asserts! (> amount u0) ERR-INVALID-INPUT)
    (var-set total-fund-balance (+ (var-get total-fund-balance) amount))
    (ok amount)
  )
)

(define-public (apply-for-grant
  (survivor-id (buff 32))
  (grant-type uint)
  (amount uint)
  (purpose (buff 128))
)
  (let
    (
      (grant-id (var-get next-grant-id))
    )
    (asserts! (default-to false (map-get? authorized-coordinators tx-sender)) ERR-NOT-AUTHORIZED)
    (asserts! (> (len survivor-id) u0) ERR-INVALID-INPUT)
    (asserts! (<= grant-type u5) ERR-INVALID-INPUT)
    (asserts! (> amount u0) ERR-INVALID-INPUT)

    (map-set financial-grants
      { grant-id: grant-id }
      {
        survivor-id: survivor-id,
        grant-type: grant-type,
        amount: amount,
        status: STATUS-PENDING,
        application-date: block-height,
        approval-date: u0,
        disbursement-date: u0,
        purpose: purpose,
        milestones: (list)
      }
    )

    ;; Update survivor grant history
    (map-set survivor-grants
      survivor-id
      (unwrap-panic (as-max-len?
        (append (default-to (list) (map-get? survivor-grants survivor-id)) grant-id)
        u20
      ))
    )

    (var-set next-grant-id (+ grant-id u1))
    (ok grant-id)
  )
)

(define-public (approve-grant (grant-id uint))
  (let
    (
      (grant (unwrap! (map-get? financial-grants { grant-id: grant-id }) ERR-GRANT-NOT-FOUND))
    )
    (asserts! (default-to false (map-get? authorized-coordinators tx-sender)) ERR-NOT-AUTHORIZED)
    (asserts! (is-eq (get status grant) STATUS-PENDING) ERR-INVALID-INPUT)
    (asserts! (>= (var-get total-fund-balance) (get amount grant)) ERR-INSUFFICIENT-FUNDS)

    (var-set total-fund-balance (- (var-get total-fund-balance) (get amount grant)))

    (ok (map-set financial-grants
      { grant-id: grant-id }
      (merge grant {
        status: STATUS-APPROVED,
        approval-date: block-height,
        disbursement-date: block-height
      })
    ))
  )
)

(define-public (create-training-program
  (program-name (buff 64))
  (program-type uint)
  (duration-weeks uint)
  (max-participants uint)
  (skills-taught (list 10 uint))
  (certification-offered bool)
)
  (let
    (
      (program-id (var-get next-program-id))
    )
    (asserts! (default-to false (map-get? authorized-coordinators tx-sender)) ERR-NOT-AUTHORIZED)
    (asserts! (> (len program-name) u0) ERR-INVALID-INPUT)
    (asserts! (<= program-type u4) ERR-INVALID-INPUT)
    (asserts! (> duration-weeks u0) ERR-INVALID-INPUT)

    (map-set training-programs
      { program-id: program-id }
      {
        program-name: program-name,
        program-type: program-type,
        duration-weeks: duration-weeks,
        max-participants: max-participants,
        current-participants: u0,
        skills-taught: skills-taught,
        certification-offered: certification-offered,
        job-placement-rate: u0
      }
    )

    (var-set next-program-id (+ program-id u1))
    (ok program-id)
  )
)

(define-public (enroll-in-program
  (survivor-id (buff 32))
  (program-id uint)
)
  (let
    (
      (enrollment-id (var-get next-enrollment-id))
      (program (unwrap! (map-get? training-programs { program-id: program-id }) ERR-PROGRAM-NOT-FOUND))
    )
    (asserts! (default-to false (map-get? authorized-coordinators tx-sender)) ERR-NOT-AUTHORIZED)
    (asserts! (> (len survivor-id) u0) ERR-INVALID-INPUT)
    (asserts! (< (get current-participants program) (get max-participants program)) ERR-INVALID-INPUT)

    (map-set program-enrollments
      { enrollment-id: enrollment-id }
      {
        survivor-id: survivor-id,
        program-id: program-id,
        enrollment-date: block-height,
        completion-date: u0,
        status: STATUS-ACTIVE,
        progress-percentage: u0,
        employment-outcome: false
      }
    )

    ;; Update program participant count
    (map-set training-programs
      { program-id: program-id }
      (merge program {
        current-participants: (+ (get current-participants program) u1)
      })
    )

    (var-set next-enrollment-id (+ enrollment-id u1))
    (ok enrollment-id)
  )
)

(define-public (update-program-progress
  (enrollment-id uint)
  (progress-percentage uint)
  (employment-outcome bool)
)
  (let
    (
      (enrollment (unwrap! (map-get? program-enrollments { enrollment-id: enrollment-id }) ERR-INVALID-INPUT))
    )
    (asserts! (default-to false (map-get? authorized-coordinators tx-sender)) ERR-NOT-AUTHORIZED)
    (asserts! (<= progress-percentage u100) ERR-INVALID-INPUT)

    (let
      (
        (new-status (if (is-eq progress-percentage u100) STATUS-COMPLETED STATUS-ACTIVE))
        (completion-date (if (is-eq progress-percentage u100) block-height u0))
      )
      (ok (map-set program-enrollments
        { enrollment-id: enrollment-id }
        (merge enrollment {
          progress-percentage: progress-percentage,
          status: new-status,
          completion-date: completion-date,
          employment-outcome: employment-outcome
        })
      ))
    )
  )
)

;; Read-only functions
(define-read-only (get-grant (grant-id uint))
  (map-get? financial-grants { grant-id: grant-id })
)

(define-read-only (get-training-program (program-id uint))
  (map-get? training-programs { program-id: program-id })
)

(define-read-only (get-enrollment (enrollment-id uint))
  (map-get? program-enrollments { enrollment-id: enrollment-id })
)

(define-read-only (get-survivor-grants (survivor-id (buff 32)))
  (map-get? survivor-grants survivor-id)
)

(define-read-only (get-fund-balance)
  (var-get total-fund-balance)
)

(define-read-only (is-authorized-coordinator (coordinator principal))
  (default-to false (map-get? authorized-coordinators coordinator))
)

(define-read-only (calculate-total-grants-awarded (survivor-id (buff 32)))
  (let
    (
      (grant-ids (default-to (list) (map-get? survivor-grants survivor-id)))
    )
    (fold calculate-grant-sum grant-ids u0)
  )
)

(define-private (calculate-grant-sum (grant-id uint) (sum uint))
  (match (map-get? financial-grants { grant-id: grant-id })
    grant (if (is-eq (get status grant) STATUS-APPROVED)
            (+ sum (get amount grant))
            sum
          )
    sum
  )
)
