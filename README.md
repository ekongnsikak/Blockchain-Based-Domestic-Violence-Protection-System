# Blockchain-Based Domestic Violence Protection System

A comprehensive smart contract system built on the Stacks blockchain to provide coordinated support and protection for domestic violence survivors.

## System Overview

This system consists of five interconnected smart contracts that work together to provide holistic support:

### 1. Threat Assessment Contract (`threat-assessment.clar`)
- Evaluates domestic violence risk levels using standardized assessment criteria
- Generates safety planning recommendations based on risk scores
- Maintains confidential assessment records with controlled access
- Provides risk escalation alerts for immediate intervention

### 2. Safe House Network Contract (`safe-house-network.clar`)
- Coordinates secure shelter placement across a network of safe houses
- Manages capacity tracking and availability in real-time
- Handles confidential placement requests and approvals
- Maintains security protocols for location privacy

### 3. Legal Protection Coordination Contract (`legal-protection.clar`)
- Manages restraining order applications and status tracking
- Coordinates with legal aid services and court systems
- Provides evidence collection and documentation support
- Tracks legal case progress and outcomes

### 4. Economic Empowerment Contract (`economic-empowerment.clar`)
- Provides financial assistance through secure fund distribution
- Manages job training program enrollment and progress
- Coordinates with employment partners for job placement
- Tracks economic independence milestones

### 5. Children's Safety Contract (`childrens-safety.clar`)
- Ensures protection protocols for children affected by domestic violence
- Coordinates with child protective services when necessary
- Manages educational support and counseling services
- Tracks child welfare outcomes and safety metrics

## Key Features

- **Privacy-First Design**: All sensitive data is encrypted and access-controlled
- **Interoperability**: Contracts work together to provide comprehensive support
- **Transparency**: Non-sensitive operations are recorded on-chain for accountability
- **Emergency Response**: Rapid response protocols for high-risk situations
- **Multi-Stakeholder**: Supports collaboration between shelters, legal aid, social services, and law enforcement

## Security Considerations

- Role-based access control for different user types
- Encryption of all personally identifiable information
- Audit trails for all system interactions
- Emergency override capabilities for life-threatening situations
- Regular security assessments and updates

## Getting Started

1. Install dependencies: `npm install`
2. Run tests: `npm test`
3. Deploy contracts: `clarinet deploy`

## Testing

The system includes comprehensive tests covering:
- Contract functionality and edge cases
- Access control and security measures
- Inter-contract communication
- Emergency response scenarios

## Contributing

This system is designed to save lives. All contributions should prioritize survivor safety and privacy.
