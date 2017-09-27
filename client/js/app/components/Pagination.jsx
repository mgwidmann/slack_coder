import React, { Component } from 'react';

export default class Pagination extends Component {
  renderPage(page, gotoPage, pageText) {
    return (
      <li key={page} className={this.props.page == page ? 'active' : null}>
        <a className="" href='javascript:void(0);' onClick={() => { gotoPage(page) }}>{pageText}</a>
      </li>
    );
  }

  render() {
    let { totalPages, page, gotoPage } = this.props;
    let startPage = page - 3 >= 1 ? page - 3 : 1;
    let endPage = page + 3 < totalPages ? page + 3 : totalPages;
    let pages = Array.apply(null, {length: endPage - startPage + 1}).map(Number.call, Number).map((i)=> i + startPage);
    return (
      <nav>
        <ul className="pagination">
          {page - 1 >= 1 ? (
            this.renderPage(page - 1, gotoPage, <span>&lt;&lt;</span>)
          ) : null}
          {pages.map((pageToRender) => {
            return this.renderPage(pageToRender, gotoPage, pageToRender);
          })}
          {page + 1 <= totalPages ? (
            this.renderPage(page + 1, gotoPage, <span>&gt;&gt;</span>)
          ) : null}
        </ul>
      </nav>
    );
  }
}
