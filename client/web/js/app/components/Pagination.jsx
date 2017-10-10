import React, { Component } from 'react';
import PropTypes from 'prop-types';
import { Link } from 'react-router-dom';

const Pagination = ({ totalPages, page, gotoPage }) => {
  const renderPage = (renderPage, pageText) => {
    return (
      <li key={renderPage} className={page == renderPage ? 'active' : null}>
        <Link className="" to='#' onClick={() => { gotoPage(renderPage) }}>{pageText}</Link>
      </li>
    );
  }
  let startPage = page - 3 >= 1 ? page - 3 : 1;
  let endPage = page + 3 < totalPages ? page + 3 : totalPages;
  let pages = Array.apply(null, {length: endPage - startPage + 1}).map(Number.call, Number).map((i)=> i + startPage);
  return (
    <nav>
      <ul className="pagination">
        {page - 1 >= 1 ? (
          renderPage(page - 1, <span>&lt;&lt;</span>)
        ) : null}
        {pages.map((pageToRender) => {
          return renderPage(pageToRender, pageToRender);
        })}
        {page + 1 <= totalPages ? (
          renderPage(page + 1, <span>&gt;&gt;</span>)
        ) : null}
      </ul>
    </nav>
  );
}

Pagination.propTypes = {
  totalPages: PropTypes.number.isRequired,
  page: PropTypes.number.isRequired,
  gotoPage: PropTypes.func.isRequired
}

export default Pagination;
