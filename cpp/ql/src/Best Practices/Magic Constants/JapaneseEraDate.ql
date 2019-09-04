/**
 * @name Hard-coded Japanese era start date
 * @description Japanese era changes can lead to code behaving differently. Avoid hard-coding Japanese era start dates.
 * @kind problem
 * @problem.severity warning
 * @id cpp/japanese-era/exact-era-date
 * @precision medium
 * @tags reliability
 *       japanese-era
 */

import cpp
import semmle.code.cpp.commons.DateTime

predicate assignedYear(Struct s, YearFieldAccess year, int value) {
  exists(Operation yearAssignment |
    s.getAField().getAnAccess() = year and
    yearAssignment.getAnOperand() = year and
    yearAssignment.getAnOperand().getValue().toInt() = value
  )
}

predicate assignedMonth(Struct s, MonthFieldAccess month, int value) {
  exists(Operation monthAssignment |
    s.getAField().getAnAccess() = month and
    monthAssignment.getAnOperand() = month and
    monthAssignment.getAnOperand().getValue().toInt() = value
  )
}

predicate assignedDay(Struct s, DayFieldAccess day, int value) {
  exists(Operation dayAssignment |
    s.getAField().getAnAccess() = day and
    dayAssignment.getAnOperand() = day and
    dayAssignment.getAnOperand().getValue().toInt() = value
  )
}

predicate badStructInitialization(Element target, string message) {
  exists(StructLikeClass s, YearFieldAccess year, MonthFieldAccess month, DayFieldAccess day |
    assignedYear(s, year, 1989) and
    assignedMonth(s, month, 1) and
    assignedDay(s, day, 8) and
    target = year and
    message = "A time struct that is initialized with exact Japanese calendar era start date."
  )
}

predicate badCall(Element target, string message) {
  exists(Call cc, int i |
    cc.getArgument(i).getValue().toInt() = 1989 and
    cc.getArgument(i + 1).getValue().toInt() = 1 and
    cc.getArgument(i + 2).getValue().toInt() = 8 and
    target = cc and
    message = "Call that appears to have hard-coded Japanese era start date as parameter."
  )
}

from Element target, string message
where
  badStructInitialization(target, message) or
  badCall(target, message)
select target, message
