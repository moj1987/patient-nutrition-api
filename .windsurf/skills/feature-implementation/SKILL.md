---
name: feature-implementation
description: Guide for implementing features using a structured approach similar to OpenSpec.
---

# Feature Implementation Skill

This skill provides a structured workflow for implementing features, inspired by the OpenSpec methodology used in this project.

## When to Use This Skill

Use this skill when you need to:
- Implement a new feature or capability
- Add functionality to the application
- Make architectural changes
- Plan and execute complex changes

## Three-Stage Workflow

### Stage 1: Planning and Analysis

**Before you start:**
- [ ] Review existing code structure and patterns
- [ ] Check for similar implementations in the codebase
- [ ] Understand the current architecture
- [ ] Identify affected files and dependencies

**Key Questions to Ask:**
- What is the specific user need this feature addresses?
- What are the acceptance criteria?
- Are there any existing patterns we should follow?
- What are the potential risks or edge cases?

### Stage 2: Design and Specification

**Create a clear plan:**
1. **Define the scope** - What exactly will be built?
2. **Identify requirements** - What must the feature do?
3. **Plan the implementation** - How will it be built?
4. **Consider edge cases** - What could go wrong?

**Documentation to create:**
- Feature description and user stories
- Technical approach and design decisions
- Implementation checklist
- Testing strategy

### Stage 3: Implementation

**Follow this sequence:**
1. **Set up foundation** - Models, migrations, basic structure
2. **Implement core logic** - Main functionality
3. **Add interfaces** - Controllers, API endpoints
4. **Integrate with existing code** - Connect to current system
5. **Write tests** - Ensure reliability
6. **Refine and optimize** - Clean up and improve

## Best Practices

### Code Quality
- Follow existing code patterns and conventions
- Keep changes minimal and focused
- Write clear, self-documenting code
- Add appropriate error handling

### Testing
- Write tests alongside implementation
- Cover happy path and edge cases
- Test integration with existing functionality
- Ensure backward compatibility when needed

### Documentation
- Update relevant documentation
- Add code comments for complex logic
- Document any new patterns or conventions

## Rails-Specific Guidelines

### Models
- Follow Rails conventions for naming and relationships
- Include appropriate validations
- Use callbacks judiciously
- Consider performance implications

### Controllers
- Keep actions focused and small
- Use strong parameters
- Handle errors gracefully
- Follow RESTful patterns when appropriate

### Database
- Write clear migration files
- Consider indexes for performance
- Plan for data integrity
- Think about future schema changes

## Example Workflow

Let's say you're adding a "meal tracking" feature:

### Stage 1: Analysis
- Review existing `Patient` and `FoodItem` models
- Understand current nutrition tracking patterns
- Identify where meal tracking fits in the architecture

### Stage 2: Design
- Define `Meal` model with relationships
- Plan API endpoints for meal CRUD operations
- Design user interface requirements
- Create implementation checklist

### Stage 3: Implementation
1. Create `Meal` model and migration
2. Add model validations and relationships
3. Implement controller actions
4. Create API routes
5. Write tests for all components
6. Update documentation

## Validation and Review

Before considering a feature complete:
- [ ] All tests pass
- [ ] Code follows project conventions
- [ ] Documentation is updated
- [ ] Feature meets acceptance criteria
- [ ] No obvious performance or security issues

## Common Pitfalls to Avoid

- **Over-engineering** - Start simple, add complexity only when needed
- **Ignoring existing patterns** - Look for similar implementations first
- **Skipping tests** - Tests are essential for reliability
- **Poor error handling** - Consider what happens when things go wrong
- **Documentation neglect** - Future developers will thank you

## Getting Help

If you're stuck:
1. Review similar features in the codebase
2. Check Rails documentation and best practices
3. Ask for clarification on requirements
4. Consider breaking the feature into smaller pieces

Remember: The goal is to build reliable, maintainable features that serve user needs while fitting seamlessly into the existing codebase.

[Reference supporting files in this directory as needed]
