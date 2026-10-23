# SOST20131 / SOST30031
# WEEK 3 PRACTICAL: CAUSAL DAGs WITH DAGITTY
#
# The focus is causal reasoning: confounders, mediators, colliders,
# backdoor paths, and adjustment sets.


# ============================================================
# SESSION AIMS
# ============================================================
# By the end of this practical, you should be able to:
#
# 1. Represent causal assumptions using a directed acyclic graph (DAG).
# 2. Distinguish confounders, mediators, and colliders.
# 3. Identify backdoor paths between an exposure and an outcome.
# 4. Use Dagitty to identify sufficient adjustment sets.
# 5. Explain why adjusting for every available variable can be a mistake.


# ============================================================
# 0. SET-UP
# ============================================================
# We will use the R package "dagitty".
#
# Install this package ONLY if you do not already have it:

install.packages("dagitty")
library(dagitty)

# You can also explore the same DAGs visually using the Dagitty web interface:
# https://dagitty.net/dags.html


# ============================================================
# RESEARCH QUESTION
# ============================================================
# We will use one substantive question throughout:
#
#   What is the TOTAL causal effect of education on earnings?
#
# Exposure: Education
# Outcome: Earnings
#
# IMPORTANT:
# A DAG does not prove that the arrows are correct.
# It represents the causal assumptions we are making.


# ============================================================
# 1. A SIMPLE DAG: CONFOUNDING
# ============================================================
# Suppose parental socioeconomic position (Parental_SES) affects both:
#   - a person's education
#   - their later earnings
#
# Complete the DAG below by adding the missing arrows.
#
# Expected causal assumptions:
#   Parental_SES -> Education
#   Parental_SES -> Earnings
#   Education -> Earnings

dag1 <- dagitty('dag {
  Education [exposure]
  Earnings [outcome]

   Parental_SES -> Education
   Parental_SES -> Earnings
   Education -> Earnings

}')

plot(dag1)


# QUESTIONS
#
# Q1. What is the causal path from Education to Earnings?
# Education -> Earnings


# Q2. Is there a backdoor path between Education and Earnings?
#     If yes, write it down.
# Yes. The backdoor path is:
# Education <- Parental_SES -> Earnings
# It is a backdoor path because it enters Education through an arrow
# pointing INTO the exposure.



# Q3. Which variable is the confounder?
# Parental_SES is a confounder because it is a common cause of
# Education and Earnings.

# Q4. Before asking Dagitty, which variable do you think we should adjust for?
# We should adjust for Parental_SES to block the backdoor path.

# Now ask Dagitty:
adjustmentSets(dag1)
#
# Q5. Does Dagitty agree with your answer?
# Yes. { Parental_SES }
# Optional: list the paths between Education and Earnings.
paths(dag1, from = "Education", to = "Earnings")
# [1] "Education -> Earnings"                 "Education <- Parental_SES -> Earnings"


# ============================================================
# 2. ADDING A MEDIATOR
# ============================================================
# Now suppose education affects occupation, which then affects earnings.
#
# Add Occupation as a mediator:
#
#   Education -> Occupation -> Earnings
#
# Keep the relationships from DAG 1.

dag2 <- dagitty('dag {
  Education [exposure]
  Earnings [outcome]

  Parental_SES -> Education
  Parental_SES -> Earnings
  Education -> Earnings

  Education -> Occupation -> Earnings

}')

plot(dag2)


# QUESTIONS
#
# Q6. What role does Occupation play in this DAG?
# Occupation is a mediator:
# Education -> Occupation -> Earnings


# Q7. We want the TOTAL effect of Education on Earnings.
# No, not if the target is the TOTAL causal effect of Education on Earnings.
# Adjusting for Occupation would block part of the causal pathway through
# which Education affects Earnings.


# Q8. Ask Dagitty for a sufficient adjustment set.
adjustmentSets(dag2)
# { Parental_SES }


# Q9. Is Occupation included in the adjustment set?
# Occupation should not be included in a sufficient adjustment set for
# estimating the TOTAL effect.

# Q10. What part of the causal effect would we remove if we controlled
#      for Occupation?
# Controlling for Occupation would remove the indirect effect operating through:
#
# Education -> Occupation -> Earnings
#
# The remaining estimate would therefore no longer represent the total effect.



# ============================================================
# 3. ADDING A COLLIDER
# ============================================================
# Now consider employment status.
#
# Suppose:
#   Education -> Employment
#   Health -> Employment
#   Health -> Earnings
#
# Employment is therefore a common effect of Education and Health.
#
# Complete the DAG.

dag3 <- dagitty('dag {
  Education [exposure]
  Earnings [outcome]

  Parental_SES -> Education
  Parental_SES -> Earnings

  Education -> Earnings
  Education -> Occupation
  Occupation -> Earnings


    Education -> Employment
   Health -> Employment
  Health -> Earnings

}')

plot(dag3)


# QUESTIONS
#
# Q11. What role does Employment play on the path:
# Employment is a collider on:
#
# Education -> Employment <- Health -> Earnings
#
# Two arrowheads meet at Employment.


# Q12. Is this path open or closed if we do NOT condition on Employment?
# The path is closed when we do NOT condition on Employment.
#
# Colliders block paths by default.



# Q13. What can happen if we control for Employment?
#  Conditioning on Employment can OPEN this path:
#
# Education -> Employment <- Health -> Earnings
#
# This can induce an association between Education and Health and create
# collider bias.


# Q14. Imagine that our dataset contains earnings only for people who are
#      currently employed. Why could this create a problem?
# If Earnings is observed only among employed people, we are effectively
# selecting/conditioning on Employment.
#
# Because Employment is a collider in this DAG, restricting the sample to
# employed people can open a non-causal path between Education and Earnings.
#
# This is an example of selection/collider bias.


# Now ask Dagitty for an adjustment set for the TOTAL effect:
adjustmentSets(dag3)
# { Parental_SES }


# Q15. Does Dagitty tell us to adjust for:
#      (a) Parental_SES? YES.
#     It is a confounder and must be controlled for to block:
#Education <- Parental_SES -> Earnings

#      (b) Occupation? NO, for the total effect.
#     It is a mediator and lies on a causal pathway.

#      (c) Employment? NO.
#     It is a collider on a path that is otherwise blocked.

#
# Explain each answer using the terms confounder, mediator, and collider.


# ============================================================
# 4. EXTENSION: MODIFY THE DAG
# ============================================================
# Choose ONE of the following:
#
# A. Add Age as a common cause of Education and Earnings.
# B. Add Ability as a common cause of Education and Earnings
