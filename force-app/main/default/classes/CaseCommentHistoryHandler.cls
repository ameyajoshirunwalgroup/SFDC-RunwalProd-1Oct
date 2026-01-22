public class CaseCommentHistoryHandler {
    public static void updateCommentHistory(List<Case> newList, Map<Id, Case> oldMap, Boolean isInsert, Boolean isUpdate) {
        String userName = UserInfo.getName();
        String timeStamp = String.valueOf(Datetime.now().format('dd-MMM-yyyy hh:mm a'));

        for (Case c : newList) {
            String commentRows = '';

            if (isUpdate && oldMap != null) {
                Case oldC = oldMap.get(c.Id);

                // Description change
                if (c.RM_Comment_For_Functional_User__c != oldC.RM_Comment_For_Functional_User__c) {
                    commentRows += buildRow(timeStamp, userName,  c.RM_Comment_For_Functional_User__c, false);
                }

                // RW Resolution Comments change
                if (c.RW_Resolution_Comments__c != oldC.RW_Resolution_Comments__c) {
                    commentRows += buildRow(timeStamp, userName, 
                         c.RW_Resolution_Comments__c, false);
                }
            }

            if (isInsert) {
                if (c.Description != null) {
                    commentRows += buildRow(timeStamp, userName,  c.Description, true);
                }
                if (c.RW_Resolution_Comments__c != null) {
                    commentRows += buildRow(timeStamp, userName,  c.RW_Resolution_Comments__c, true);
                }
            }

            // Append to Comment_History__c if something changed
            if (!String.isBlank(commentRows)) {
                String existingHistory = c.Comment_History__c;

                // If no existing table, create one with borders
                if (String.isBlank(existingHistory)) {
                    existingHistory =
                        '<table border="1" cellpadding="5" cellspacing="0" style="border-collapse:collapse;width:100%;border:1px solid #000;">' +
                        '<thead style="background-color:#f2f2f2;">' +
                        '<tr><th>Date/Time</th><th>User</th><th>New Value</th></tr>' +
                        '</thead><tbody>' + commentRows + '</tbody></table>';
                } else if (existingHistory.contains('</tbody></table>')) {
                    // Append new rows *inside tbody*, before closing tag
                    existingHistory = existingHistory.replace('</tbody></table>', commentRows + '</tbody></table>');
                } else if (existingHistory.contains('</table>')) {
                    // Fallback: if only </table> exists
                    existingHistory = existingHistory.replace('</table>', commentRows + '</table>');
                } else {
                    // In case of malformed content, just append new table
                    existingHistory +=
                        '<table border="1" cellpadding="5" cellspacing="0" style="border-collapse:collapse;width:100%;border:1px solid #000;">' +
                        '<thead style="background-color:#f2f2f2;">' +
                        '<tr><th>Date/Time</th><th>User</th><th>New Value</th></tr>' +
                        '</thead><tbody>' + commentRows + '</tbody></table>';
                }

                c.Comment_History__c = existingHistory;
            }
        }
    }

    private static String buildRow(String timeStamp, String userName,  String newValue, Boolean isInsert) {
        String newVal = (newValue == null ? '(empty)' : newValue.escapeHtml4());

        return '<tr>' +
               '<td>' + timeStamp + '</td>' +
               '<td>' + userName.escapeHtml4() + '</td>' +
               '<td>' + newVal + '</td>' +
               '</tr>';
    }
}