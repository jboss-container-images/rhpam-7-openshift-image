package org.openshift.quickstarts.rhpam.kieserver.library;

import java.util.Collection;

import org.junit.BeforeClass;
import org.junit.Test;
import org.openshift.quickstarts.rhpam.kieserver.library.types.Book;
import org.openshift.quickstarts.rhpam.kieserver.library.types.Loan;

import static org.hamcrest.CoreMatchers.is;
import static org.hamcrest.CoreMatchers.not;
import static org.hamcrest.Matchers.emptyCollectionOf;
import static org.junit.Assert.assertThat;

public class LibraryTest {

    private static final Library LIBRARY = Library.library();

    @BeforeClass
    public static void init() {
        LIBRARY.init();
    }

    @Test
    public void whenGetFirstAvailableHGWellsBookIsOk() {
        final Collection<Book> books = LIBRARY.getFirstAvailableBooks("Time Machine");
        assertThat(books, is(not(emptyCollectionOf(Book.class))));
    }

    @Test
    public void whenLoanABookSucceed() {
        final Book book = LIBRARY.getFirstAvailableBooks("World").stream().findFirst().get();
        final Loan loan = LIBRARY.attemptLoan(book.getIsbn(), 1);
        assertThat(loan.isApproved(), is(true));
    }

    @Test
    public void whenLoanAndThenReturnSucceed() {
        final Book book = LIBRARY.getFirstAvailableBooks("Time Machine").stream().findFirst().get();
        final Loan loan = LIBRARY.attemptLoan(book.getIsbn(), 2);
        assertThat(LIBRARY.returnLoan(loan), is(true));
    }

}
