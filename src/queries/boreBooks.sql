WITH Books_Lang_Count AS (
    SELECT title, author, COUNT(DISTINCT language) AS lang_count
    FROM editions
    GROUP BY title, author
),
Valid_Books AS (
    SELECT title, author
    FROM Books_Lang_Count
    WHERE lang_count >= 3
),
Loaned_Books AS (
    SELECT DISTINCT e.title, e.author
    FROM editions e
    JOIN copies c ON e.isbn = c.isbn
    JOIN loans l ON c.signature = l.signature
    WHERE l.type = 'L'
)
SELECT DISTINCT b.title, b.author
FROM books b
JOIN Valid_Books vb ON b.title = vb.title AND b.author = vb.author
WHERE NOT EXISTS (
    SELECT 1
    FROM Loaned_Books lb
    WHERE lb.title = b.title AND lb.author = b.author
)
ORDER BY b.title;
